# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit desktop eutils rpm xdg-utils

IUSE=""

DESCRIPTION="Microsoft Teams Linux Client"
HOMEPAGE="https://teams.microsoft.com/"
SRC_URI="https://packages.microsoft.com/yumrepos/ms-teams/${P}-1.x86_64.rpm"
LICENSE="GitHub"
SLOT="0"
KEYWORDS="amd64"

RDEPEND="
	!app-office/teams-insiders
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
RESTRICT="primaryuri mirror strip"

S="${WORKDIR}"

src_unpack() {
	rpm_unpack ${A}
}

src_install() {
	local dest=/usr

	# Remove keytar3, it needs libgnome-keyring. keytar4 uses libsecret and is used instead
	rm -rf "${WORKDIR}/usr/share/teams/resources/app.asar.unpacked/node_modules/keytar3" || die

	insinto ${dest}/share
	doins -r "${S}"${dest}/share/applications
	doins -r "${S}"${dest}/share/pixmaps
	doins -r "${S}"${dest}/share/${PN}

	exeinto ${dest}/bin
	doexe "${S}"${dest}/bin/${PN}

	exeinto ${dest}/share/${PN}
	doexe "${S}"${dest}/share/${PN}/${PN}

	sed -i '/OnlyShowIn=/d' "${S}"${dest}/share/applications/${PN}.desktop
	domenu "${S}"${dest}/share/applications/${PN}.desktop
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
}
