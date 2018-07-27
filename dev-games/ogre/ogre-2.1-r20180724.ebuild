# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils cmake-utils mercurial

DESCRIPTION="Object-oriented Graphics Rendering Engine"
HOMEPAGE="http://www.ogre3d.org/"

EHG_REPO_URI="https://bitbucket.org/sinbad/ogre"
EHG_REVISION="b9f5f58b4f84cbf5b8f4923de4061e1f78dd1f78"
SRC_URI=""

LICENSE="MIT public-domain"
SLOT="0/2.1"
KEYWORDS=""

IUSE="+cache debug doc egl examples +freeimage gles2 json +legacy-animations
	mobile ois +opengl profile tools"

# USE flags that do not work, as their options aren't ported, yet.
#	cg
#	double-precision

REQUIRED_USE="
	|| ( gles2 opengl )
	examples? ( ois )
	mobile? ( egl gles2 !opengl )"

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
	egl? ( media-libs/mesa[egl] )
	freeimage? ( media-libs/freeimage )
	gles2? ( media-libs/mesa[gles2] )
	json? ( dev-libs/rapidjson )
	ois? ( dev-games/ois )"
# Dependencies for USE flags that do not work, yet.
#	cg? ( media-gfx/nvidia-cg-toolkit )
DEPEND="${RDEPEND}
	virtual/pkgconfig
	x11-base/xorg-proto
	doc? ( app-doc/doxygen )"

PATCHES=(
	"${FILESDIR}/${P}-samples.patch"
	"${FILESDIR}/${P}-resource_path.patch"
	"${FILESDIR}/${P}-media_path.patch"
	"${FILESDIR}/${P}-enhance_config_loading.patch"
)

src_unpack() {
	mercurial_src_unpack
}

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
		-DOGRE_BUILD_COMPONENT_HLMS_PBS=$(         usex mobile no yes)
		-DOGRE_BUILD_COMPONENT_HLMS_PBS_MOBILE=$(  usex mobile)
		-DOGRE_BUILD_COMPONENT_HLMS_UNLIT=$(       usex mobile no yes)
		-DOGRE_BUILD_COMPONENT_HLMS_UNLIT_MOBILE=$(usex mobile)
		-DOGRE_BUILD_COMPONENT_PLANAR_REFLECTIONS=yes
		-DOGRE_BUILD_COMPONENT_SCENE_FORMAT=yes
		-DOGRE_BUILD_RENDERSYSTEM_GL3PLUS=$(usex opengl)
		-DOGRE_BUILD_RENDERSYSTEM_GLES=no
		-DOGRE_BUILD_RENDERSYSTEM_GLES2=$(usex gles2)
		-DOGRE_BUILD_SAMPLES2=$(usex examples)
		-DOGRE_BUILD_TESTS=no
		-DOGRE_BUILD_TOOLS=$(usex tools)
		-DOGRE_CONFIG_ENABLE_FREEIMAGE=$(usex freeimage)
		-DOGRE_CONFIG_ENABLE_GL_STATE_CACHE_SUPPORT=$(usex cache)
		-DOGRE_CONFIG_ENABLE_GLES3_SUPPORT=$(\
			usex gles2 $(\
			usex mobile no yes) no)
		-DOGRE_CONFIG_ENABLE_JSON=$(usex json)
		-DOGRE_CONFIG_THREADS=2
		-DOGRE_CONFIG_THREAD_PROVIDER=std
		-DOGRE_FULL_RPATH=no
		-DOGRE_INSTALL_DOCS=$(usex doc)
		-DOGRE_INSTALL_SAMPLES=$(usex examples)
		-DOGRE_INSTALL_SAMPLES_SOURCE=$(usex examples)
		-DOGRE_LEGACY_ANIMATIONS=$(usex legacy-animations)
		-DOGRE_PROFILING_PROVIDER=$(usex profile none internal)
		-DOGRE_USE_BOOST=no
	)
	# Options that aren't ported, yet:
	#	-DOGRE_BUILD_PLUGIN_CG=$(usex cg)
	#	-DOGRE_CONFIG_DOUBLE=$(usex double-precision)

	# These components are off by default, as they might not be ported, yet.
	# When advancing to a newer commit, try whether any of the disabled
	# components can be activated now.
	mycmakeargs+=(
		-DOGRE_BUILD_COMPONENT_PAGING=no
		-DOGRE_BUILD_COMPONENT_PROPERTY=no
		-DOGRE_BUILD_COMPONENT_RTSHADERSYSTEM=no
		-DOGRE_BUILD_RTSHADERSYSTEM_CORE_SHADERS=no
		-DOGRE_BUILD_RTSHADERSYSTEM_EXT_SHADERS=no
		-DOGRE_BUILD_COMPONENT_TERRAIN=no
		-DOGRE_BUILD_COMPONENT_VOLUME=no
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
	doins "${CMAKE_BUILD_DIR}"/bin/plugins_tools.cfg
	doins "${CMAKE_BUILD_DIR}"/bin/resources.cfg
	doins "${CMAKE_BUILD_DIR}"/bin/resources2.cfg
	dosym "${CONFIGDIR}"/plugins.cfg "${SHAREDIR}"/plugins.cfg
	dosym "${CONFIGDIR}"/plugins_tools.cfg "${SHAREDIR}"/plugins_tools.cfg
	dosym "${CONFIGDIR}"/resources.cfg "${SHAREDIR}"/resources.cfg
	dosym "${CONFIGDIR}"/resources2.cfg "${SHAREDIR}"/resources2.cfg

	# These are only for the Samples
	if use examples ; then
		insinto "${SHAREDIR}"
		doins "${CMAKE_BUILD_DIR}"/bin/samples.cfg
	fi
}
