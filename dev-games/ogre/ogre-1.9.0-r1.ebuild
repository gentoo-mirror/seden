# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-games/ogre/ogre-1.9.0.ebuild,v 1.3 2014/03/08 23:22:37 hasufell Exp $

EAPI=5
CMAKE_REMOVE_MODULES="yes"
CMAKE_REMOVE_MODULES_LIST="FindFreetype"

inherit eutils cmake-utils vcs-snapshot versionator

MY_PV=$(get_version_component_range 1-3)
MY_P=${PN}-${MY_PV}

LIBDIR=/usr/$(get_libdir)/OGRE
SHAREDIR=/usr/share/OGRE
SAMPLEDIR=${LIBDIR}/Samples
TESTDIR=/usr/local/share/OGRE

DESCRIPTION="Object-oriented Graphics Rendering Engine"
HOMEPAGE="http://www.ogre3d.org/"
SRC_URI="https://bitbucket.org/sinbad/ogre/get/v${PV//./-}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="MIT public-domain"
SLOT="0/1.9.0"
KEYWORDS="~amd64 ~x86"
IUSE="\
    +boost cg doc double-precision examples +freeimage gl3plus gles1 gles2 \
    gles3 ois +opengl poco profile tbb threads tools +zip"
REQUIRED_USE="threads? ( ^^ ( boost poco tbb ) )
	poco? ( threads )
	tbb? ( threads )
	gles1? ( !gl3plus )
	gles2? ( !gl3plus )
	gles3? ( ( !gl3plus ) ( gles2 ) )
	gl3plus? ( ( opengl ) ( !gles1 ) ( !gles2 ) ( !gles3 ) )"
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
	gles1? ( >=media-libs/mesa-8.0.0[gles1] )
	gles2? ( >=media-libs/mesa-9.0.0[gles2] )
	gles3? ( >=media-libs/mesa-10.0.0[gles2] )
	gl3plus? ( >=media-libs/mesa-9.2.5 )
	ois? ( dev-games/ois )
	threads? (
		poco? ( dev-libs/poco )
		tbb? ( dev-cpp/tbb )
	)
	zip? ( sys-libs/zlib dev-libs/zziplib )"
# gles1 currently broken wrt bug #418201
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
		$(cmake-utils_use gles1 OGRE_BUILD_RENDERSYSTEM_GLES)
		$(cmake-utils_use gles2 OGRE_BUILD_RENDERSYSTEM_GLES2)
		$(cmake-utils_use gles3 OGRE_CONFIG_ENABLE_GLES3_SUPPORT)
		$(cmake-utils_use profile OGRE_PROFILING)
		$(cmake-utils_use examples OGRE_BUILD_SAMPLES)
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

	# Unfortunately cmake has put its detected paths into the config files.
	# plugins.cfg:
	#   /home/portage/dev-games/ogre-1.9.0/work/ogre-1.9.0_build/lib
	sed -i \
		-e "s,${CMAKE_BUILD_DIR}/lib,${LIBDIR},g" \
		"${CMAKE_BUILD_DIR}"/bin/plugins.cfg || \
		die "Fixing plugins.cfg failed"
	# quakemap: 
	#   /home/portage/dev-games/ogre-1.9.0/work/ogre-1.9.0/Samples/Media/packs/chiropteraDM.pk3
	sed -i \
		-e "s,${WORKDIR}/${MY_P}/Samples,${SHAREDIR}," \
		"${CMAKE_BUILD_DIR}"/bin/quakemap.cfg || \
		die "Fixing quakemap.cfg failed"
	# resources.cfg: 
	#  /home/portage/dev-games/ogre-1.9.0/work/ogre-1.9.0/Samples
	#  /home/portage/dev-games/ogre-1.9.0/work/ogre-1.9.0/Tests
	sed -i \
		-e "s,${WORKDIR}/${MY_P}/Samples,${SHAREDIR},g" \
		-e "s,${WORKDIR}/${MY_P}/Tests,${TESTDIR}," \
		"${CMAKE_BUILD_DIR}"/bin/resources.cfg || \
		die "Fixing resources.cfg failed"
	# samples.cfg:
	#   /home/portage/dev-games/ogre-1.9.0/work/ogre-1.9.0_build/lib
	sed -i \
		-e "s,${CMAKE_BUILD_DIR}/lib,${LIBDIR}/Samples,g" \
		"${CMAKE_BUILD_DIR}"/bin/samples.cfg || \
		die "Fixing samples.cfg failed"

	# tests.cfg is not needed
}

src_install() {
	cmake-utils_src_install

	## Those are no longer just examples but the real configuration of the
	#  current system. They belong in /etc/OGRE, as those were always
	#  there, and there they are config protected.
	#  However, ogre looks in /usr/share/OGRE for them, so they must be
	#  symlinked there as well.
	#  - Sven
	# docinto examples
	# dodoc "${CMAKE_BUILD_DIR}"/bin/*.cfg

	# plugins and resources are the main configuration
	insinto /etc/OGRE
	doins "${CMAKE_BUILD_DIR}"/bin/plugins.cfg
	doins "${CMAKE_BUILD_DIR}"/bin/resources.cfg
	dosym /etc/OGRE/plugins.cfg ${SHAREDIR}/plugins.cfg
	dosym /etc/OGRE/resources.cfg ${SHAREDIR}/resources.cfg

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
