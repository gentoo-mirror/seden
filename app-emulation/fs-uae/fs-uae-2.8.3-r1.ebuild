# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools gnome2-utils xdg-utils

DESCRIPTION="FS-UAE integrates the most accurate Amiga emulation code available from WinUAE."
HOMEPAGE="https://fs-uae.net/"
SRC_URI="https://fs-uae.net/stable/${PV}/${P}.tar.gz"
LICENSE="GPL-2"
KEYWORDS="amd64 x86"
SLOT="0"
IUSE="drivers glew qt5"

RDEPEND="
	glew?	( media-libs/glew:0 )
	qt5?	( dev-qt/qtgui:5 )
	media-libs/libmpeg2
	media-libs/libpng:0
	media-libs/libsdl2[opengl]
	media-libs/openal
	virtual/opengl
	x11-libs/libdrm
	x11-libs/libX11
"

DEPEND="sys-devel/gettext
	${RDEPEND}
"

PATCHES=(
	"${FILESDIR}"/${P}_libmpeg2.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf	--enable-a2065 \
		--enable-action-replay \
		--enable-aga \
		--enable-arcadia \
		--enable-bsdsocket \
		--enable-caps \
		--enable-cd32 \
		--enable-cdtv \
		--enable-codegen \
		--enable-dms \
		--enable-drivesound \
		--enable-fdi2raw \
		--enable-gfxboard \
		--with-glad \
		--enable-jit \
		--enable-jit-fpu \
		--enable-ncr9x \
		--enable-ncr \
		--enable-netplay \
		--enable-parallel-port \
		--enable-prowizard \
		--enable-qemu-cpu \
		--enable-qemu-slirp \
		--enable-savestate \
		--enable-scp \
		--enable-serial-port \
		--enable-slirp \
		--enable-softfloat \
		--with-libmpeg2 \
		--enable-uaenative \
		--enable-uaenet \
		--enable-uaescsi \
		--enable-uaeserial \
		--enable-udis86 \
		--enable-vpar \
		--enable-xml-shader \
		--enable-zip \
		$(use_enable drivers) \
		$(use_with glew) \
		$(use_with qt5 qt)
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update

	elog
	elog "Install app-emulation/fs-uae-launcher for a graphical interface."
	elog
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
