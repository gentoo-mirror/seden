# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils versionator

MY_P=${PN}-src-${PV}
MY_PV=$(get_version_component_range 1-2)
MY_P2=${PN}-${MY_PV}

DESCRIPTION="A game entity layer based on Crystal Space"
HOMEPAGE="http://cel.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"

LICENSE="LGPL-2"
KEYWORDS="~amd64 ~x86"
IUSE="python"

SLOT="0"

RDEPEND=">=dev-games/crystalspace-${PV}
	dev-games/hawknl"
DEPEND="${RDEPEND}
	dev-util/ftjam"

S=${WORKDIR}/${MY_P}

src_configure() {
	chmod +x configure
	econf \
		--disable-separate-debug-info \
		--disable-cstest \
		$(use_with python) \
		|| die
}

src_compile() {
	jam -q || die "jam failed"
}

src_install() {
	jam -q -s DESTDIR="${D}" install || die "jam install failed"

	# Fill cache directory for the examples
	cp "${D}"/usr/share/${MY_P2}/data/{basic_,}world
	cslight -video=null "${D}"/usr/share/${MY_P2}/data
	cp "${D}"/usr/share/${MY_P2}/data/{walktut_,}world
	cslight -video=null "${D}"/usr/share/${MY_P2}/data
	rm "${D}"/usr/share/${MY_P2}/data/world

	dodoc docs/history*.txt docs/todo.txt
}
