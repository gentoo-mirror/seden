# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
CMAKE_REMOVE_MODULES="yes"
CMAKE_REMOVE_MODULES_LIST="FindFreetype"

inherit eutils cmake-utils vcs-snapshot versionator

MY_PV=$(get_version_component_range 1-3)

DESCRIPTION="Object-oriented Graphics Rendering Engine"
HOMEPAGE="http://www.ogre3d.org/"
SRC_URI="https://bitbucket.org/sinbad/ogre/get/v${PV//./-}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="MIT public-domain"
SLOT="0/1.9.0"
KEYWORDS="~amd64 ~x86"

# gles1 currently broken wrt bug #418201
# gles1 does not even build wrt bug #506058
IUSE="\
    +boost cg doc double-precision examples +freeimage gl3plus gles2 \
    gles3 ois +opengl poco profile source tbb threads tools +zip"

REQUIRED_USE="threads? ( ^^ ( boost poco tbb ) )
	poco? ( threads )
	tbb? ( threads )
	gles2? ( !gl3plus )
	gles3? ( ( !gl3plus ) ( gles2 ) )
	gl3plus? ( ( opengl ) ( !gles2 ) ( !gles3 ) )"

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
	boost? ( dev-libs/boost )
	cg? ( media-gfx/nvidia-cg-toolkit )
	freeimage? ( media-libs/freeimage )
	gles2? ( >=media-libs/mesa-9.0.0[gles2] )
	gles3? ( >=media-libs/mesa-10.0.0[gles2] )
	gl3plus? ( >=media-libs/mesa-9.2.5 )
	ois? ( dev-games/ois )
	threads? (
		poco? ( dev-libs/poco )
		tbb? ( dev-cpp/tbb )
	)
	zip? ( sys-libs/zlib dev-libs/zziplib )"

DEPEND="${RDEPEND}
	x11-proto/xf86vidmodeproto
	virtual/pkgconfig
	doc? ( app-doc/doxygen )"

src_prepare() {
	sed -i \
		-e "s:share/OGRE/docs:share/doc/${PF}:" \
		Docs/CMakeLists.txt || die
	# Stupid build system hardcodes release names
	sed -i \
		-e '/CONFIGURATIONS/s:CONFIGURATIONS Release.*::' \
		CMake/Utils/OgreConfigTargets.cmake || die

	# Fix some path issues
	epatch "${FILESDIR}/${MY_PV}-01_remove_resource_path_to_bindir.patch"
	epatch "${FILESDIR}/${MY_PV}-02_remove_media_path_to_bindir.patch"

	# With gcc 5+, template definitions in compilation units, even if
	# guaranteed to be instantiatet with the requred type there, can
	# no longer be used in another compilation unit. (Undefined reference
	# while linking
	# Bug : 559472
	if [[ $(gcc-major-version) = 5 ]]; then
		epatch "${FILESDIR}/${MY_PV}-03_move_stowed_template_func.patch"
	fi
}

src_configure() {
	local mycmakeargs=(
		-DOGRE_FULL_RPATH=NO
		$(cmake-utils_use boost OGRE_USE_BOOST)
		$(cmake-utils_use cg OGRE_BUILD_PLUGIN_CG)
		$(cmake-utils_use doc OGRE_INSTALL_DOCS)
		$(cmake-utils_use double-precision OGRE_CONFIG_DOUBLE)
		$(cmake-utils_use examples OGRE_INSTALL_SAMPLES)
		$(cmake-utils_use freeimage OGRE_CONFIG_ENABLE_FREEIMAGE)
		$(cmake-utils_use opengl OGRE_BUILD_RENDERSYSTEM_GL)
		$(cmake-utils_use gl3plus OGRE_BUILD_RENDERSYSTEM_GL3PLUS)
		-DOGRE_BUILD_RENDERSYSTEM_GLES=FALSE
		$(cmake-utils_use gles2 OGRE_BUILD_RENDERSYSTEM_GLES2)
		$(cmake-utils_use gles3 OGRE_CONFIG_ENABLE_GLES3_SUPPORT)
		$(cmake-utils_use profile OGRE_PROFILING)
		$(cmake-utils_use examples OGRE_BUILD_SAMPLES)
		$(cmake-utils_use source OGRE_INSTALL_SAMPLES_SOURCE)
		-DOGRE_BUILD_TESTS=FALSE
		$(usex threads "-DOGRE_CONFIG_THREADS=2" "-DOGRE_CONFIG_THREADS=0")
		$(cmake-utils_use tools OGRE_BUILD_TOOLS)
		$(cmake-utils_use zip OGRE_CONFIG_ENABLE_ZIP)
	)

	if use threads ; then
		local f
		for f in boost poco tbb ; do
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