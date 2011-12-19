# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit cmake-utils subversion

DESCRIPTION="GiGi is an OpenGL interface library"
HOMEPAGE="http://gigi.sourceforge.net"
ESVN_REPO_URI="https://${PN}.svn.sourceforge.net/svnroot/${PN}/trunk"
ESVN_PROJECT="${PN}"

LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~x86"
IUSE="debug devil doc ogre ois +sdl static-libs +threads"

SLOT="0"

RDEPEND="
	>=dev-libs/boost-1.47
	media-libs/freetype
	x11-libs/libX11
	virtual/opengl
	devil? ( >=media-libs/devil-1.6.1 )
	!devil? (
		media-libs/jpeg
		media-libs/tiff
		media-libs/libpng
	)
	ogre?	(
		||	(	>=dev-games/ogre-1.4.7[threads=]
					||	(	threads?	(
									||	(	>=dev-games/ogre-1.7.1[boost-threads]
												>=dev-games/ogre-1.7.1[poco-threads]
												>=dev-games/ogre-1.7.1[tbb-threads]
											)
									)
							 	!threads?	(
												>=dev-games/ogre-1.7.1[-boost-threads,-poco-threads,-tbb-threads]
									)
							)
				)
		)
	ois? ( dev-games/ois )
	sdl? ( >=media-libs/libsdl-1.2 )
"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	sys-devel/libtool:2
	doc? ( app-doc/doxygen )
"

CMAKE_USE_DIR="${S}/GG"

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	# remove libtool
	cd "${CMAKE_USE_DIR}"
	rm -rf libltdl/ || die "Removing libltdl directory failed"
	# remove cmake calls to libtool
	epatch "${FILESDIR}/unbundle-ltdl.patch"
	# use system headers
	sed -i \
		-e "s:GG/ltdl.h:ltdl.h:" \
		GG/PluginInterface.h || die "switching to system ltdl.h in GG/PluginInterface.h failed"
	# Change deprecated /usr/doc/GG to /usr/share/doc/${P}
	sed -i \
		-e "s:doc/GG:doc/${P}:" \
		CMakeLists.txt || die "changing doc/GG to doc/${P} failed"
	sed -i \
		-e "s:DESTINATION doc:DESTINATION share/doc:" \
		CMakeLists.txt || die "changing /usr/doc to /usr/share/doc failed"
	sed -i \
		-e "s:HTML_OUTPUT\(.*\)= GG:HTML_OUTPUT\1= ${P}:" \
		doc/Doxyfile || die "changing doxygen output from GG to ${P} failed"
}

src_configure() {
	use ogre && use ois && mycmakeargs=( "-DBUILD_OGRE_OIS_PLUGIN=ON" ) || mycmakeargs=( "-DBUILD_OGRE_OIS_PLUGIN=OFF" )
	mycmakeargs+=(
		"-DBUILD_TUTORIALS=OFF"
		$(cmake-utils_use_build debug)
		$(cmake-utils_use devil)
		$(cmake-utils_use_build doc DOCUMENTATION)
		$(cmake-utils_use_build ogre OGRE_DRIVER)
		$(cmake-utils_use_build sdl SDL_DRIVER)
		$(cmake-utils_use_build static-libs STATIC)
		$(cmake-utils_use_build threads MULTI_THREADED)
	)

	cmake-utils_src_configure
}
