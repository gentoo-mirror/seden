# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools eutils flag-o-matic

DESCRIPTION="FS-UAE integrates the most accurate Amiga emulation code available from WinUAE."
HOMEPAGE="https://fs-uae.net/"
SRC_URI="https://fs-uae.net/stable/${PV}/${P}.tar.gz"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
SLOT="0"
IUSE="	+a2065 +action-replay +aga +arcadia +bsdsocket +capsimage +cd32 +cdtv
	+codegen +dms drivers +drivesound +fdi2raw +gfxboard +glad glew +jit
	+jit-fpu +ncr9x +ncr +netplay +parallel-port +prowizard
	+qemu-cpu +qemu-slirp qt +savestate +scp +serial-port +slirp +softfloat
	+system-libmpeg2 +uaenative +uaenet +uaescsi +uaeserial +udis86 +vpar
	+xml-shader +zip"

REQUIRED_USE="
	qemu-slirp?	( slirp )
"

RDEPEND="
	glew?			( media-libs/glew:0 )
	qt?			( dev-qt/qtgui:5 )
	system-libmpeg2?	( media-libs/libmpeg2 )
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
	econf	$(use_enable a2065) \
		$(use_enable action-replay) \
		$(use_enable aga) \
		$(use_enable arcadia) \
		$(use_enable bsdsocket) \
		$(use_enable capsimage caps) \
		$(use_enable cd32) \
		$(use_enable cdtv) \
		$(use_enable codegen) \
		$(use_enable dms) \
		$(use_enable drivers) \
		$(use_enable drivesound) \
		$(use_enable fdi2raw) \
		$(use_enable gfxboard) \
		$(use_with glad) \
		$(use_with glew) \
		$(use_enable jit) \
		$(use_enable jit-fpu) \
		$(use_enable ncr9x) \
		$(use_enable ncr) \
		$(use_enable netplay) \
		$(use_enable parallel-port) \
		$(use_enable prowizard) \
		$(use_enable qemu-cpu) \
		$(use_enable qemu-slirp) \
		$(use_with qt) \
		$(use_enable savestate) \
		$(use_enable scp) \
		$(use_enable serial-port) \
		$(use_enable slirp) \
		$(use_enable softfloat) \
		$(usex system-libmpeg2 --with-libmpeg2 --with-libmpeg2=builtin) \
		$(use_enable uaenative) \
		$(use_enable uaenet) \
		$(use_enable uaescsi) \
		$(use_enable uaeserial) \
		$(use_enable udis86) \
		$(use_enable vpar) \
		$(use_enable xml-shader) \
		$(use_enable zip)
}

pkg_postinst() {
	elog
	elog "Install app-emulation/fs-uae-launcher for a graphical interface."
	elog
}
