# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop

MY_PN=glfrontier
MY_P=${MY_PN}-${PV}
DESCRIPTION="Frontier: Elite 2 with OpenGL support"
HOMEPAGE="https://www.frontierastro.co.uk/Hires/hiresfe2.html"

SRC_URI="https://prydeworx.com/glfrontier/frontvm3-20060623.tar.bz2
	https://prydeworx.com/glfrontier/frontvm-audio-20060222.tar.bz2"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE=""

SLOT="0"

RDEPEND="
	>=media-libs/freeglut-2.6
	media-libs/libsdl
	media-libs/libogg"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${MY_P}"-fix_missing_math_lib.patch
)

S=${WORKDIR}

src_compile() {
	emake -C frontvm3-20060623 -f Makefile-C || die "make install failed"
}

src_install() {
	mv frontvm3-20060623/frontier frontvm3-20060623/${MY_PN}

	exeinto /usr/bin
	doexe frontvm3-20060623/${MY_PN}

	insinto /usr/share/${MY_PN}
	doins frontvm3-20060623/fe2.s.bin
	doins -r frontvm-audio-20060222/*

	make_desktop_entry "${EPREFIX:-/}"usr/share/${MY_PN}/${MY_PN} GLFrontier \
		${MY_PN} Game Path=/usr/share/${MY_PN}
}
