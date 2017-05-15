# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit eutils cmake-utils vcs-snapshot versionator

MY_PV=$(get_version_component_range 1-3)

DESCRIPTION="Object-oriented Graphics Rendering Engine"
HOMEPAGE="http://www.ogre3d.org/"
SRC_URI="https://bitbucket.org/sinbad/ogre/get/v${PV//./-}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="MIT public-domain"
SLOT="0/1.10.0"
KEYWORDS="~amd64 ~x86"

IUSE="\
    +boost cg doc double-precision examples +freeimage gl3plus gles2 \
    gles3 ois +opengl poco profile source tbb threads tools +zip"

REQUIRED_USE="
	gl3plus?	( !gles2 !gles3 opengl )
	gles2?		( !gl3plus )
	gles3?		( !gl3plus gles2 )
	poco?		( !tbb threads )
	tbb?		( !poco threads )
	threads? 	( || ( boost poco tbb ) )
"

RESTRICT="test" #139905

RDEPEND="
	dev-libs/tinyxml
	media-libs/freetype:2
	virtual/opengl
	virtual/glu
	x11-libs/libX11
	x11-libs/libXaw
	x11-libs/libXrandr
	x11-libs/libXt
	boost?		( dev-libs/boost )
	cg?			( media-gfx/nvidia-cg-toolkit )
	freeimage?	( media-libs/freeimage )
	gles2?		( media-libs/mesa[gles2] )
	gl3plus?	( || (
					media-libs/mesa[dri3]
					x11-drivers/nvidia-drivers
					x11-drivers/xf86-video-amdgpu
				) )
	ois?		( dev-games/ois )
	opengl?		( virtual/opengl )
	poco?		( dev-libs/poco )
	tbb?		( dev-cpp/tbb )
	zip?		( sys-libs/zlib dev-libs/zziplib )"

DEPEND="${RDEPEND}
	x11-proto/xf86vidmodeproto
	virtual/pkgconfig
	doc? ( app-doc/doxygen )"

PATCHES=(
	"${FILESDIR}"/1.10.4-01_remove_resource_path_to_bindir.patch
	"${FILESDIR}"/1.10.4-02_remove_media_path_to_bindir.patch
)

src_prepare() {

	default

	sed -i \
		-e "s:share/OGRE/docs:share/doc/${PF}:" \
		Docs/CMakeLists.txt || die
	# Stupid build system hardcodes release names
	sed -i \
		-e '/CONFIGURATIONS/s:CONFIGURATIONS Release.*::' \
		CMake/Utils/OgreConfigTargets.cmake || die

}

src_configure() {
	local mycmakeargs=(
		-DOGRE_FULL_RPATH=NO
		-DOGRE_BUILD_PLUGIN_CG="$(usex cg)"
		-DOGRE_INSTALL_DOCS="$(usex doc)"
		-DOGRE_CONFIG_DOUBLE="$(usex double-precision)"
		-DOGRE_INSTALL_SAMPLES="$(usex examples)"
		-DOGRE_CONFIG_ENABLE_FREEIMAGE="$(usex freeimage)"
		-DOGRE_BUILD_DEPENDENCIES=FALSE
		-DOGRE_BUILD_RENDERSYSTEM_GL="$(usex opengl)"
		-DOGRE_BUILD_RENDERSYSTEM_GL3PLUS="$(usex gl3plus)"
		-DOGRE_BUILD_RENDERSYSTEM_GLES2="$(usex gles2)"
		-DOGRE_CONFIG_ENABLE_GLES3_SUPPORT="$(usex gles3)"
		-DOGRE_GLSUPPORT_USE_EGL=FALSE
		-DOGRE_PROFILING="$(usex profile)"
		-DOGRE_BUILD_SAMPLES="$(usex examples)"
		-DOGRE_INSTALL_SAMPLES_SOURCE="$(usex source)"
		-DOGRE_BUILD_TESTS=FALSE
		-DOGRE_CONFIG_THREADS=$(usex threads 2 0)
		-DOGRE_BUILD_TOOLS="$(usex tools)"
		-DOGRE_CONFIG_ENABLE_ZIP="$(usex zip)"
	)

	if use threads ; then
		local f
		for f in poco tbb boost ; do
			use ${f} || continue
			mycmakeargs+=( -DOGRE_CONFIG_THREAD_PROVIDER=${f} )
			break
		done
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	CONFIGDIR=/etc/OGRE
	SHAREDIR=/usr/share/OGRE
	TESTDIR=/usr/local/share/OGRE
	
	# plugins and resources are the main configuration
	insinto ${CONFIGDIR}
	doins "${CMAKE_BUILD_DIR}"/bin/plugins.cfg
	doins "${CMAKE_BUILD_DIR}"/bin/resources.cfg
	dosym ${CONFIGDIR}/plugins.cfg ${SHAREDIR}/plugins.cfg
	dosym ${CONFIGDIR}/resources.cfg ${SHAREDIR}/resources.cfg

	# The testdir needs to be created
	mkdir -p "${D}/${TESTDIR}"

	# Use video group, as OGRE is a rendering engine you need to be in the
	# video group to use anyway. (Ogre3D is not a game engine, actually I
	# think dev-games is the wrong category anyway.)
	chown :video "${D}/${TESTDIR}"
	chmod g+rwX "${D}/${TESTDIR}"

	# These are only for the sample browser
	insinto ${SHAREDIR}
	doins "${CMAKE_BUILD_DIR}"/bin/quakemap.cfg
	doins "${CMAKE_BUILD_DIR}"/bin/samples.cfg

	# tests.cfg is not needed
}
