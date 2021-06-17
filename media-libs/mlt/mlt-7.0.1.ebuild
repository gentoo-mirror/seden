# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

LUA_COMPAT=( lua5-{1..4} luajit )
PYTHON_COMPAT=( python3_{7,8,9} )
inherit cmake lua python-single-r1 toolchain-funcs

DESCRIPTION="Open source multimedia framework for television broadcasting"
HOMEPAGE="https://www.mltframework.org/"
SRC_URI="https://github.com/mltframework/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~ppc64 ~x86 ~amd64-linux ~x86-linux"
IUSE="compressed-lumas debug
ffmpeg fftw frei0r gtk jack kernel_linux libsamplerate lua opencv opengl python
qt5 rtaudio rubberband sdl sox vdpau vidstab vorbis xine xml"
# java perl php tcl

REQUIRED_USE="lua? ( ${LUA_REQUIRED_USE} )
	python? ( ${PYTHON_REQUIRED_USE} )"

SWIG_DEPEND=">=dev-lang/swig-2.0"
#	java? ( ${SWIG_DEPEND} >=virtual/jdk-1.5 )
#	perl? ( ${SWIG_DEPEND} )
#	php? ( ${SWIG_DEPEND} )
#	tcl? ( ${SWIG_DEPEND} )
#	ruby? ( ${SWIG_DEPEND} )
BDEPEND="
	virtual/pkgconfig
	compressed-lumas? ( virtual/imagemagick-tools[png] )
	lua? ( ${SWIG_DEPEND} virtual/pkgconfig )
	python? ( ${SWIG_DEPEND} )
"
#rtaudio will use OSS on non linux OSes
DEPEND="
	>=media-libs/libebur128-1.2.2:=
	ffmpeg? ( media-video/ffmpeg:0=[vdpau?,-flite] )
	fftw? ( sci-libs/fftw:3.0= )
	frei0r? ( media-plugins/frei0r-plugins )
	gtk? (
		media-libs/libexif
		x11-libs/pango
	)
	jack? (
		>=dev-libs/libxml2-2.5
		media-libs/ladspa-sdk
		virtual/jack
	)
	libsamplerate? ( >=media-libs/libsamplerate-0.1.2 )
	lua? ( ${LUA_DEPS} )
	opencv? ( >=media-libs/opencv-4.5.1:= )
	opengl? ( media-video/movit )
	python? ( ${PYTHON_DEPS} )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtsvg:5
		dev-qt/qtwidgets:5
		dev-qt/qtxml:5
		media-libs/libexif
		x11-libs/libX11
	)
	rtaudio? (
		>=media-libs/rtaudio-4.1.2
		kernel_linux? ( media-libs/alsa-lib )
	)
	rubberband? ( media-libs/rubberband )
	sdl? (
		media-libs/libsdl2[X,opengl,video]
		media-libs/sdl2-image
	)
	vidstab? ( media-libs/vidstab )
	vorbis? ( media-libs/libvorbis )
	xine? ( >=media-libs/xine-lib-1.1.2_pre20060328-r7 )
	xml? ( >=dev-libs/libxml2-2.5 )
	sox? ( media-sound/sox )"
#	java? ( >=virtual/jre-1.5 )
#	perl? ( dev-lang/perl )
#	php? ( dev-lang/php )
#	ruby? ( ${RUBY_DEPS} )
#	tcl? ( dev-lang/tcl:0= )
RDEPEND="${DEPEND}"

DOCS=( AUTHORS COPYING NEWS README.md docs/mlt++.txt )

PATCHES=(
	"${FILESDIR}"/${PN}-6.10.0-swig-underlinking.patch
	"${FILESDIR}"/${PN}-6.22.1-no_lua_bdepend.patch
	"${FILESDIR}"/${P}-fix_man_symlink.patch
	"${FILESDIR}"/${P}-remove-rpath.patch
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare

	# respect CFLAGS LDFLAGS when building shared libraries. Bug #308873
	for x in python lua; do
		sed -i "/mlt.so/s/ -lmlt++ /& ${CFLAGS} ${LDFLAGS} /" src/swig/$x/build || die
	done

	use python && python_fix_shebang src/swig/python
}

src_configure() {
	tc-export CC CXX

	local mycmakeargs=(
		-DGPL=YES
		-DGPL3=YES
		-DMOD_KDENLIVE=YES
		-DMOD_NORMALIZE=YES
		-DMOD_OLDFILM=YES
		-DMOD_AVFORMAT=$(usex ffmpeg)
		-DMOD_FREI0R=$(usex frei0r)
		-DMOD_GDK=$(usex gtk)
		-DMOD_JACKRACK=$(usex jack)
		-DMOD_MOVIT=$(usex opengl)
		-DMOD_OPENCV=$(usex opencv)
		-DMOD_PLUS=$(usex fftw)
		-DMOD_PLUSGPL=$(usex fftw)
		-DMOD_QT=$(usex qt5)
		-DMOD_RESAMPLE=$(usex libsamplerate)
		-DMOD_RTAUDIO=$(usex rtaudio)
		-DMOD_RUBBERBAND=$(usex rubberband)
		-DMOD_SDL2=$(usex sdl)
		-DMOD_SOX=$(usex sox)
		-DMOD_VIDSTAB=$(usex vidstab)
		-DMOD_VORBIS=$(usex vorbis)
		-DMOD_XINE=$(usex xine)
		-DMOD_XML=$(usex xml)
		-DSWIG_LUA=$(usex lua)
		-DSWIG_PYTHON=$(usex python)
	)

	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	if use lua; then
		# Only copy sources now to avoid unnecessary rebuilds
		local BUILD_ori="${BUILD_DIR}"
		BUILD_DIR="${S}"

		lua_copy_sources

		lua_compile() {
			pushd "${BUILD_DIR}"/src/swig/lua > /dev/null || die

			sed -i -e "s| mlt_wrap.cxx| $(lua_get_CFLAGS) mlt_wrap.cxx|" build || die
			./build

			popd > /dev/null || die
		}
		lua_foreach_impl lua_compile

		BUILD_DIR="${BUILD_ori}"
	fi
}

src_install() {
	cmake_src_install

	doman docs/melt.1

	insinto /usr/share/${PN}
	doins -r demo

	# link back pkgconfig files for backwards compatibility
	dosym "mlt++-7.pc"         "/usr/$(get_libdir)/pkgconfig/mlt++.pc"
	dosym "mlt-framework-7.pc" "/usr/$(get_libdir)/pkgconfig/mlt-framework.pc"

	# Link back libraries for backwards compatibility
	dosym "libmlt++-7.so" "/usr/$(get_libdir)/libmlt++.so"
	dosym "libmlt-7.so"   "/usr/$(get_libdir)/libmlt.so"

	#
	# Install SWIG bindings
	#

	docinto swig

	if use lua; then
		local BUILD_ori="${BUILD_DIR}"
		BUILD_DIR="${S}"

		lua_install() {
			pushd "${BUILD_ori}"/out/lib > /dev/null || die

			exeinto "$(lua_get_cmod_dir)"
			doexe mlt.so

			popd > /dev/null || die
		}
		lua_foreach_impl lua_install

		dodoc "${S}"/src/swig/lua/play.lua

		BUILD_DIR="${BUILD_ori}"
	fi

	if use python; then
		cd "${BUILD_DIR}"/src/swig/python || die
		python_domodule mlt.py

		cd "${BUILD_DIR}"/out/lib || die
		python_domodule _mlt7.so
		chmod +x "${D}$(python_get_sitedir)/_mlt7.so" || die

		cd "${S}"/src/swig/python || die
		dodoc play.py

		python_optimize
	fi

	# not done: java perl php ruby tcl
}
