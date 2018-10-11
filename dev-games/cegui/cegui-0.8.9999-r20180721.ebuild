# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# TODO: multiple ABI?
PYTHON_COMPAT=( python2_7 )
inherit eutils flag-o-matic cmake-utils mercurial python-single-r1

DESCRIPTION="Crazy Eddie's GUI System"
HOMEPAGE="http://www.cegui.org.uk/"

EHG_REPO_URI="https://bitbucket.org/cegui/cegui"
EHG_REVISION="9b075344b4b4ff6bed972c68adfdb86dca7499a1"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="bidi debug devil doc freeimage expat irrlicht lua ogre opengl pcre python static-libs tinyxml truetype xerces-c +xml zip"
REQUIRED_USE="|| ( expat tinyxml xerces-c xml )
	${PYTHON_REQUIRED_USE}" # bug 362223

# gles broken
#	gles? ( media-libs/mesa[gles1] )
# directfb broken
#	directfb? ( dev-libs/DirectFB )
RDEPEND="
	dev-libs/boost:=
	virtual/libiconv
	bidi? ( dev-libs/fribidi )
	devil? ( media-libs/devil )
	expat? ( dev-libs/expat )
	freeimage? ( media-libs/freeimage )
	irrlicht? ( dev-games/irrlicht )
	lua? (
		dev-lang/lua:0
		dev-lua/toluapp
	)
	ogre? ( >=dev-games/ogre-1.7:= )
	opengl? (
		virtual/opengl
		virtual/glu
		media-libs/glew:=
	)
	pcre? ( dev-libs/libpcre )
	python? (
		${PYTHON_DEPS}
		dev-libs/boost:=[python,${PYTHON_USEDEP}]
	)
	tinyxml? ( dev-libs/tinyxml )
	truetype? ( media-libs/freetype:2 )
	xerces-c? ( dev-libs/xerces-c )
	xml? ( dev-libs/libxml2 )
	zip? ( sys-libs/zlib[minizip] )"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
	opengl? ( media-libs/glm )"

PATCHES=(
	"${FILESDIR}"/${P}-icu-59.patch
	"${FILESDIR}"/${P}-fix_ogre_cxx11.patch
)

src_unpack() {
	mercurial_src_unpack
}

src_configure() {
	# http://www.cegui.org.uk/mantis/view.php?id=991
	# append-ldflags $(no-as-needed)

	local mycmakeargs=(
		-DCEGUI_BUILD_IMAGECODEC_CORONA=OFF
		-DCEGUI_BUILD_IMAGECODEC_DEVIL="$(usex devil)"
		-DCEGUI_BUILD_IMAGECODEC_FREEIMAGE="$(usex freeimage)"
		-DCEGUI_BUILD_IMAGECODEC_PVR=OFF
		-DCEGUI_BUILD_IMAGECODEC_SILLY=OFF
		-DCEGUI_BUILD_IMAGECODEC_STB=ON
		-DCEGUI_BUILD_IMAGECODEC_TGA=ON
		-DCEGUI_BUILD_LUA_GENERATOR="$(usex lua)"
		-DCEGUI_BUILD_LUA_MODULE="$(usex lua)"
		-DCEGUI_BUILD_PYTHON_MODULES="$(usex python)"
		-DCEGUI_BUILD_RENDERER_DIRECTFB=OFF
		-DCEGUI_BUILD_RENDERER_IRRLICHT="$(usex irrlicht)"
		-DCEGUI_BUILD_RENDERER_NULL=ON
		-DCEGUI_BUILD_RENDERER_OGRE="$(usex ogre)"
		-DCEGUI_BUILD_RENDERER_OPENGL="$(usex opengl)"
		-DCEGUI_BUILD_RENDERER_OPENGL3="$(usex opengl)"
		-DCEGUI_BUILD_RENDERER_OPENGLES=OFF
		-DCEGUI_BUILD_STATIC_CONFIGURATION="$(usex static-libs)"
		-DCEGUI_BUILD_TESTS=OFF
		-DCEGUI_BUILD_XMLPARSER_EXPAT="$(usex expat)"
		-DCEGUI_BUILD_XMLPARSER_LIBXML2="$(usex xml)"
		-DCEGUI_BUILD_XMLPARSER_RAPIDXML=OFF
		-DCEGUI_BUILD_XMLPARSER_TINYXML="$(usex tinyxml)"
		-DCEGUI_BUILD_XMLPARSER_XERCES="$(usex xerces-c)"
		-DCEGUI_HAS_FREETYPE="$(usex truetype)"
		-DCEGUI_HAS_MINIZIP_RESOURCE_PROVIDER="$(usex zip)"
		-DCEGUI_HAS_PCRE_REGEX="$(usex pcre)"
		-DCEGUI_SAMPLES_ENABLED=OFF
		-DCEGUI_USE_FRIBIDI="$(usex bidi)"
		-DCEGUI_USE_MINIBIDI=OFF
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
	use doc && emake -C "${BUILD_DIR}" html
}

src_install() {
	cmake-utils_src_install
	use doc && dohtml "${BUILD_DIR}"/doc/doxygen/html/*
}