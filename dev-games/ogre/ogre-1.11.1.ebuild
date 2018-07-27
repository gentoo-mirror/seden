# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="Object-oriented Graphics Rendering Engine"
HOMEPAGE="https://www.ogre3d.org/"
SRC_URI="https://github.com/OGRECave/${PN}/archive/v${PV}.zip -> ${P}.zip"

LICENSE="MIT public-domain"
SLOT="0/1.11"
KEYWORDS="~amd64 ~x86"

IUSE="beta-components +cache cg debug doc double-precision egl examples
	+freeimage gles2 json ois openexr +opengl pch profile +resman-legacy
	resman-pedantic resman-strict tools"

REQUIRED_USE="
	|| ( gles2 opengl )
	^^ ( resman-legacy resman-pedantic resman-strict )
	examples? ( ois )"

RESTRICT="test" #139905

RDEPEND="
	dev-libs/zziplib
	media-libs/freetype:2
	virtual/glu
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXaw
	x11-libs/libXrandr
	x11-libs/libXt
	cg? ( media-gfx/nvidia-cg-toolkit )
	egl? ( media-libs/mesa[egl] )
	freeimage? ( media-libs/freeimage )
	gles2? ( media-libs/mesa[gles2] )
	json? ( dev-libs/rapidjson )
	ois? ( dev-games/ois )
	openexr? ( media-libs/openexr )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	x11-base/xorg-proto
	doc? ( app-doc/doxygen )"

PATCHES=(
	"${FILESDIR}/${P}-media_path.patch"
	"${FILESDIR}/${P}-resource_path.patch"
	"${FILESDIR}/${P}-samples.patch"
	"${FILESDIR}/${P}-fix_sample_source_install.patch"
)

src_prepare() {
	sed -i \
		-e "s:share/OGRE/docs:share/doc/${PF}:" \
		Docs/CMakeLists.txt || die
	# Stupid build system hardcodes release names
	sed -i \
		-e '/CONFIGURATIONS/s:CONFIGURATIONS Release.*::' \
		CMake/Utils/OgreConfigTargets.cmake || die

	# Fix some path issues
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DOGRE_BUILD_COMPONENT_BITES=yes
		-DOGRE_BUILD_COMPONENT_HLMS=$(usex beta-components)
		-DOGRE_BUILD_COMPONENT_JAVA=no
		-DOGRE_BUILD_COMPONENT_PAGING=yes
		-DOGRE_BUILD_COMPONENT_PROPERTY=yes
		-DOGRE_BUILD_COMPONENT_PYTHON=no
		-DOGRE_BUILD_COMPONENT_RTSHADERSYSTEM=yes
		-DOGRE_BUILD_COMPONENT_TERRAIN=yes
		-DOGRE_BUILD_COMPONENT_VOLUME=yes
		-DOGRE_BUILD_DEPENDENCIES=no
		-DOGRE_BUILD_PLUGIN_CG=$(usex cg)
		-DOGRE_BUILD_PLUGIN_FREEIMAGE=$(usex freeimage)
		-DOGRE_BUILD_PLUGIN_EXRCODEC=$(usex openexr)
		-DOGRE_BUILD_RENDERSYSTEM_GL=$(usex opengl)
		-DOGRE_BUILD_RENDERSYSTEM_GL3PLUS=$(usex opengl)
		-DOGRE_BUILD_RENDERSYSTEM_GLES2=$(usex gles2)
		-DOGRE_BUILD_SAMPLES=$(usex examples)
		-DOGRE_BUILD_TESTS=no
		-DOGRE_BUILD_TOOLS=$(usex tools)
		-DOGRE_CONFIG_DOUBLE=$(usex double-precision)
		-DOGRE_CONFIG_ENABLE_GL_STATE_CACHE_SUPPORT=$(usex cache)
		-DOGRE_CONFIG_ENABLE_GLES2_CG_SUPPORT=$(usex gles2 $(usex cg) no)
		-DOGRE_CONFIG_ENABLE_GLES3_SUPPORT=$(usex gles2)
		-DOGRE_CONFIG_THREADS=3
		-DOGRE_CONFIG_THREAD_PROVIDER=std
		-DOGRE_ENABLE_PRECOMPILED_HEADERS=$(usex pch)
		-DOGRE_FULL_RPATH=no
		-DOGRE_GLSUPPORT_USE_EGL=$(usex egl)
		-DOGRE_INSTALL_DOCS=$(usex doc)
		-DOGRE_INSTALL_SAMPLES=$(usex examples)
		-DOGRE_INSTALL_SAMPLES_SOURCE=$(usex examples)
		-DOGRE_PROFILING=$(usex profile)
		-DOGRE_RESOURCEMANAGER_STRICT=$(\
			usex resman-pedantic 1 $(\
			usex resman-strict 2 0))
	)

	# Ogre3D is making use of "CMAKE_INSTALL_CONFIG_NAME MATCHES ..." and
	# sets it to BUILD_TYPE. Only RelWithDebInfo, MinSizeRel and Debug
	# are supported.
	CMAKE_BUILD_TYPE="$(usex debug Debug RelWithDebInfo)"

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	CONFIGDIR=/etc/OGRE
	SHAREDIR=/usr/share/OGRE

	# plugins and resources are the main configuration
	insinto "${CONFIGDIR}"
	doins "${CMAKE_BUILD_DIR}"/bin/plugins.cfg
	doins "${CMAKE_BUILD_DIR}"/bin/resources.cfg
	dosym "${CONFIGDIR}"/plugins.cfg "${SHAREDIR}"/plugins.cfg
	dosym "${CONFIGDIR}"/resources.cfg "${SHAREDIR}"/resources.cfg

	# Unfortunately make install forgets the samples.
	if use examples ; then
		# These are only for the sample browser
		insinto "${SHAREDIR}"
		doins "${CMAKE_BUILD_DIR}"/bin/quakemap.cfg
		doins "${CMAKE_BUILD_DIR}"/bin/samples.cfg
	fi
}
