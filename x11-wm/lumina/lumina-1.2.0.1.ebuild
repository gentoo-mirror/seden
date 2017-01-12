# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit qmake-utils versionator

DESCRIPTION="Lumina desktop environment"
HOMEPAGE="http://lumina-desktop.org/"
V_MAIN="$(get_version_component_range 1-3)"
V_PATCH="$(get_version_component_range 4)"
SRC_URI="https://github.com/trueos/${PN}/archive/v${V_MAIN}-p${V_PATCH}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="compton i18n"

COMMON_DEPEND="dev-qt/qtcore:5
	dev-qt/qtconcurrent:5
	dev-qt/qtmultimedia:5[widgets]
	dev-qt/qtsvg:5
	dev-qt/qtnetwork:5
	dev-qt/qtwidgets:5
	dev-qt/qtx11extras:5
	x11-libs/libxcb:0
	x11-libs/xcb-util
	x11-libs/xcb-util-image
	x11-libs/xcb-util-wm"

DEPEND="$COMMON_DEPEND
	dev-qt/linguist-tools:5"

RDEPEND="$COMMON_DEPEND
	kde-frameworks/oxygen-icons
	compton? ( x11-misc/compton )
	x11-misc/numlockx
	x11-wm/fluxbox
	x11-apps/xbacklight
	media-sound/alsa-utils
	sys-power/acpi
	app-admin/sysstat"

S="${WORKDIR}/${PN}-${V_MAIN}-p${V_PATCH}"

src_configure(){
	local qmake_args=(
		"PREFIX=${ROOT}usr"
		"LIBPREFIX=${ROOT}usr/$(get_libdir)"
		"L_BINDIR=${ROOT}usr/bin"
		"L_ETCDIR=${ROOT}etc"
		"L_LIBDIR=${ROOT}usr/$(get_libdir)"
		"DESTDIR=${D}"
		$(usex i18n 'CONFIG+=WITH_I18N' 'CONFIG+=NO_I18N')
	)

	eqmake5 "${qmake_args[@]}"
}

src_install(){
	# note: desktop files have known validation errors. see:
	# https://github.com/pcbsd/lumina/pull/183
	default
	mv "${D}"/etc/luminaDesktop.conf.dist "${D}"/etc/luminaDesktop.conf || die
	mv "${D}"/?umina-* "${D}"/usr/bin || die
	mv "${D}"/start-lumina-desktop "${D}"/usr/bin || die
	exeinto /etc/X11/Sessions
	newexe "${FILESDIR}/lumina-session" lumina || die
}
