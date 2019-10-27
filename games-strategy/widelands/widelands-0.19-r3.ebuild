# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit cmake-utils eapi7-ver gnome2-utils xdg-utils

MY_PV=build$(ver_cut 2)
MY_P=${PN}-${MY_PV}-src
DESCRIPTION="A game similar to Settlers 2"
HOMEPAGE="http://www.widelands.org/"
SRC_URI="https://launchpad.net/widelands/${MY_PV}/${MY_PV}/+download/${MY_P}.tar.bz2"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-lang/lua:0
	>=dev-libs/boost-1.48
	dev-libs/icu:=
	media-libs/glew:0
	media-libs/libpng:0
	media-libs/libsdl2[video]
	media-libs/sdl2-image[jpeg,png]
	media-libs/sdl2-mixer[vorbis]
	media-libs/sdl2-net
	media-libs/sdl2-ttf
	sys-libs/zlib[minizip]"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

PATCHES=(
	"${FILESDIR}"/${P}-fix_icu-61.1.patch
	"${FILESDIR}"/${P}-fix_maybe_uninitialized.patch
	"${FILESDIR}"/${P}-remove_doc_file_install.patch
)

src_prepare() {
	# This only works if uppercase
	sed -i \
		-e 's:__ppc__:__PPC__:' \
		src/map_io/s2map.cc || die
	# Stupid build system has no general rules
	sed -i \
		-e 's:RelWithDebInfo:Gentoo:' \
		CMakeLists.txt || die
	# They only install with Debug and Release, not even with RelWithDebInfo
	sed -i \
		-e '/CONFIGURATIONS Debug;Release/ s/$/;Gentoo/' \
		CMakeLists.txt || die
	# Fix some path issues
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}"/usr/bin
		-DWL_INSTALL_BASEDIR="${EPREFIX}"/usr/bin
		-DWL_INSTALL_DATADIR="${EPREFIX}"/usr/share/${PN}
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

pkg_preinst() {
	gnome2_icon_savelist
}

src_install() {
	cmake-utils_src_install
	newicon data/images/logos/wl-ico-128.png ${PN}.png
	make_desktop_entry ${PN} Widelands
	dodoc ChangeLog CREDITS
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
