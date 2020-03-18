# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit xdg-utils gnome2-utils rpm

IUSE="gnome"

DESCRIPTION="Microsoft Teams Linux Client"
HOMEPAGE="https://teams.microsoft.com/"
SRC_URI="https://teams.microsoft.com/downloads/desktopurl?env=production&plat=linux&arch=x64&download=true&linuxArchiveType=rpm -> ${P}.rpm"
LICENSE="GitHub"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	app-accessibility/at-spi2-atk
	app-crypt/libsecret
	dev-libs/atk
	dev-libs/expat
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/libXtst
	x11-libs/libxcb
	x11-libs/libxkbfile
	x11-libs/pango
"
DEPEND=""
PDEPEND=""
RESTRICT="mirror strip"

S="${WORKDIR}"

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	insinto /usr/share
	doins -r "${S}"/usr/share/applications
	doins -r "${S}"/usr/share/pixmaps
	doins -r "${S}"/usr/share/teams

	exeinto /usr/bin
	doexe "${S}"/usr/bin/teams
}

pkg_preinst() {
	use gnome && gnome2_icon_savelist
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
	use gnome && gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
	use gnome && gnome2_icon_cache_update
}
