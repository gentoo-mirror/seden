# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-build git-r3

DESCRIPTION="Faster OpenGL offloading for Bumblebee"
HOMEPAGE="https://github.com/amonakov/primus"
SRC_URI=""
EGIT_REPO_URI="git://github.com/amonakov/primus.git https://github.com/amonakov/primus.git"
EGIT_BRANCH="master"

LICENSE="ISC"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	x11-misc/bumblebee[video_cards_nvidia]
	x11-drivers/nvidia-drivers[compat]
"
DEPEND="virtual/opengl"

PATCHES=(
	"${FILESDIR}"/${PN}-support-user-LDFLAGS.patch
	"${FILESDIR}"/${PN}-add-libglvnd-workaround.patch
)

src_compile() {
	export PRIMUS_libGLa='/usr/$$LIB/opengl/nvidia/lib/libGL.so.1'
	mymake() {
		emake LIBDIR=$(get_libdir)
	}
	multilib_parallel_foreach_abi mymake
}

src_install() {
	sed -i -e "s#^PRIMUS_libGL=.*#PRIMUS_libGL='/usr/\$LIB/primus'#" primusrun
	dobin primusrun
	myinst() {
		insinto /usr/$(get_libdir)/primus
		doins $(get_libdir)/libGL.so.1
	}
	multilib_foreach_abi myinst
}
