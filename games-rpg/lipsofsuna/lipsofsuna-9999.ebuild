# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7
PYTHON_COMPAT=( python2_7 )
PYTHON_REQ_USE="threads(+)"
inherit eutils git-r3 python-any-r1 waf-utils

DESCRIPTION="Tongue-in-cheek dungeon crawl game. Client and Server."
HOMEPAGE="https://gitlab.com/xenodora/lipsofsuna"
EGIT_REPO_URI="https://gitlab.com/xenodora/lipsofsuna.git"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="iconv inotify"

DEPEND="dev-db/sqlite:3
	>=dev-lang/lua-5.1.0
	media-libs/flac
	>=media-libs/glew-1.5
	>=media-libs/libsdl-1.2
	media-libs/libvorbis
	media-libs/libogg
	media-libs/mesa
	media-libs/openal
	>=media-libs/sdl-ttf-2.0
	>=net-libs/enet-1.2.2
	>=net-misc/curl-3
	sci-physics/bullet
	>=dev-games/ogre-1.10.4
	dev-games/ois
	media-libs/freeimage
	iconv? ( virtual/libiconv )
	inotify? ( sys-fs/inotify-tools )
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/01_add_OgreOverlay_to_wscript.patch
	"${FILESDIR}"/02_add_ogre_h.patch
	"${FILESDIR}"/03_fix_member_name_change.patch
	"${FILESDIR}"/04_add_missing_includes.patch
	"${FILESDIR}"/05_add_more_missing_includes.patch
)

src_configure() {
	waf-utils_src_configure \
		--ogre-plugindir=/usr/$(get_libdir)/OGRE \
		--disable-relpath \
		--enable-optimization
}

src_install() {
	dobin .build/${PN} || die "Installation of gamesbinary failed"
	insinto /usr/share/${PN}/
	doins -r data/* || die "Installation of game data failed"
	doicon misc/${PN}.svg || die "Installation of Icon failed"
	domenu misc/${PN}.desktop || die "Installation of desktop file failed"
}
