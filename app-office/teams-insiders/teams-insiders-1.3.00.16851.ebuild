# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit eutils desktop gnome2-utils unpacker xdg-utils

IUSE="chromium gnome mate"

DESCRIPTION="Microsoft Teams Linux Client (Insiders Build)"
HOMEPAGE="https://teams.microsoft.com/"
SRC_URI="https://packages.microsoft.com/repos/ms-teams/pool/main/t/${PN}/${PN}_${PV}_amd64.deb"
LICENSE="GitHub"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	!app-office/teams
	app-accessibility/at-spi2-atk
	app-crypt/libsecret
	dev-libs/atk
	dev-libs/expat
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	gnome-base/libgnome-keyring
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
	chromium? ( media-video/ffmpeg[chromium] )
"
DEPEND=""
BDEPEND=""
PDEPEND=""
RESTRICT="primaryuri mirror strip"

S="${WORKDIR}"

src_install() {
	local dest=/usr

	insinto ${dest}/share
	doins -r "${S}"${dest}/share/applications
	doins -r "${S}"${dest}/share/pixmaps
	doins -r "${S}"${dest}/share/${PN}

	exeinto ${dest}/bin
	doexe "${S}"${dest}/bin/${PN}

	exeinto ${dest}/share/${PN}
	doexe "${S}"${dest}/share/${PN}/${PN}

	# Use system ffmpeg, needs USE=chromium, if wanted
	if use chromium; then
		rm -f "${D}"/${dest}/share/${PN}/libffmpeg.so
		dosym "${dest}/$(get_libdir)/chromium/libffmpeg.so" "${dest}/share/${PN}/libffmpeg.so"
	else
		doexe "${S}"${dest}/share/${PN}/libffmpeg.so
	fi

	# Use system mesa
	rm -f "${D}"/${dest}/share/${PN}/libEGL.so
	rm -f "${D}"/${dest}/share/${PN}/libGLESv2.so

	# Maybe keep swiftshader? Use in GPU/Head less systems
	rm -f "${D}"/${dest}/share/${PN}/swiftshader/libEGL.so
	rm -f "${D}"/${dest}/share/${PN}/swiftshader/libGLESv2.so

	sed -i '/OnlyShowIn=/d' "${S}"${dest}/share/applications/${PN}.desktop
	domenu "${S}"${dest}/share/applications/${PN}.desktop
}

pkg_preinst() {
	use gnome && gnome2_icon_savelist
	use mate && gnome2_icon_savelist
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
	use gnome && gnome2_icon_cache_update
	use mate && gnome2_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
	xdg_icon_cache_update
	use gnome && gnome2_icon_cache_update
	use mate && gnome2_icon_cache_update
}
