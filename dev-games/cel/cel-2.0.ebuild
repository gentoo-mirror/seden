# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools eutils versionator

MY_PV=$(get_version_component_range 1-2)
MY_P=${PN}-${MY_PV}

DESCRIPTION="A game entity layer based on Crystal Space"
HOMEPAGE="http://www.crystalspace3d.org/"
SRC_URI="http://www.crystalspace3d.org/downloads/release/${PN}-src-${MY_PV}.tar.bz2"
RESTRICT="mirror"

LICENSE="LGPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

SLOT="0"

RDEPEND="
  =dev-games/crystalspace-${MY_PV}*
  dev-games/hawknl"
DEPEND="${RDEPEND}
	dev-util/ftjam"

S=${WORKDIR}/${PN}-src-${MY_PV}

src_prepare() {
	# InstallDoc conflicts with dodoc
	sed -i -e "/^InstallDoc/d" docs/Jamfile \
		|| die "sed on docs/Jamfile failed"

	# remove old references to StepFast, an experimental system in ode <0.12
	epatch "${FILESDIR}"/${MY_P}-remove_ode_stepfast_01.patch
	epatch "${FILESDIR}"/${MY_P}-remove_ode_stepfast_02.patch
	epatch "${FILESDIR}"/${MY_P}-remove_ode_stepfast_03.patch
	epatch "${FILESDIR}"/${MY_P}-remove_ode_stepfast_04.patch
	epatch "${FILESDIR}"/${MY_P}-remove_ode_stepfast_05.patch
	epatch "${FILESDIR}"/${MY_P}-remove_ode_stepfast_06.patch

	AT_M4DIR=mk/autoconf
	eautoreconf
}

src_configure() {
	econf \
    --disable-separate-debug-info \
    --disable-optimize-mode-debug-info \
    --with-cs-prefix=/usr \
		$(use_enable debug) \
		|| die "configure failed"
}

src_compile() {
	local jamopts=$(echo "${MAKEOPTS}" | sed -ne "/-j/ { s/.*\(-j[[:space:]]*[0-9]\+\).*/\1/; p }")
	jam -q ${jamopts} || die "compile failed (jam -q ${jamopts})"
}

src_install() {
	jam -q -s DESTDIR="${D}" install || die "jam install failed"

	# Fill cache directory for the examples
	cp "${D}"/usr/share/${MY_P}/data/{basic_,}world
	lighter2 --simpletui "${D}"/usr/share/${MY_P}/data
	cp "${D}"/usr/share/${MY_P}/data/{walktut_,}world
	lighter2 --simpletui "${D}"/usr/share/${MY_P}/data
	rm "${D}"/usr/share/${MY_P}/data/world

	# As the target install_doc uses cel-2.0 as target, but dodoc
	# uses ${PF}, this said var has to be manipulated first.
	local oldPF=${PF}
	PF=${MY_P}
	dodoc COPYING README docs/history*.txt docs/todo.txt
	PF=${oldPF}
}
