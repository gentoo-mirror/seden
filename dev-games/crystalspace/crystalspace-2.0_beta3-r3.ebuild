# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools eutils flag-o-matic multilib java-pkg-opt-2 wxwidgets versionator

MY_PV=$(get_version_component_range 1-2)
MY_BETA="beta3"
MY_P=${PN}-${MY_PV}

DESCRIPTION="Portable 3D Game Development Kit written in C++"
HOMEPAGE="http://www.crystalspace3d.org/"
SRC_URI="http://www.crystalspace3d.org/downloads/release/${PN}-src-${MY_PV}${MY_BETA}.tar.bz2"
RESTRICT="mirror"

LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~x86"
IUSE="3ds alsa bullet cal3d cegui cg debug doc java jpeg lcms +march-native mng ode \
      +optimize perl png profile +python static-plugins speex truetype vorbis wxwidgets +X"

SLOT="0"

COMMON_DEP="virtual/opengl
	media-libs/openal
	x11-libs/libXt
	x11-libs/libXxf86vm
	cg? ( media-gfx/nvidia-cg-toolkit )
	ode? ( dev-games/ode )
	cal3d? ( >=media-libs/cal3d-0.11 )
	jpeg? ( media-libs/jpeg )
	bullet? ( sci-physics/bullet )
	vorbis? ( media-libs/libvorbis )
	speex? (	media-libs/libogg
						media-libs/speex )
	truetype? ( >=media-libs/freetype-2.1 )
	alsa? ( media-libs/alsa-lib )
	mng? ( media-libs/libmng )
	png? ( media-libs/libpng )
	wxwidgets? ( x11-libs/wxGTK:2.8[X,opengl] )
	cegui? ( >=dev-games/cegui-0.5.0 )
	3ds? ( media-libs/lib3ds )"

RDEPEND="${COMMON_DEP}
	java? ( >=virtual/jre-1.5 )"

DEPEND="${COMMON_DEP}
	java? ( >=virtual/jdk-1.5
		dev-java/ant-core )
	dev-lang/swig
	dev-util/pkgconfig
  dev-util/ftjam"

S=${WORKDIR}/${PN}-src-${MY_PV}${MY_BETA}

src_prepare() {

	# Installing doc conflict with dodoc on src_install
	# Removing conflicting target
	sed -i \
		-e "/^InstallDoc/d" \
		Jamfile.in \
		docs/Jamfile \
		|| die "sed failed"

	AT_M4DIR=mk/autoconf
	eautoreconf
}

src_configure() {
	local myconf

	if use wxwidgets ; then
		WX_GTK_VER="2.8"
		need-wxwidgets gtk2
	fi

	# As flags are managed by debug, optimize and profile USE flags,
	# they need to be removed first. If we do not do this, the calling
	# lines grow so large, that jam segfaults.
	CFLAGS=""
	CXXFLAGS=""
	LDFLAGS=""
	# This is quite contrary to the "gentoo way", but the configuration
	# script runs in exactly one mode, optimize (default), profile or
	# debug. All of these enable different CFLAGS and LDFLAGS. And to
	# make this even more complicated, configure knows a bunch of arguments
	# for a lot of LDFLAGS, too. I have not found a way to disable them
	# all, ending up with a lot of redundant or even negating flag
	# arrangements.

	# debug profile and optimize are mutually exclusive
	if use debug ; then
		myconf="--enable-debug --disable-optimize --disable-profile"
		if use optimize ; then
			ewarn "debug version chosen, optimize USE flag ignored."
		fi
		if use profile ; then
			ewarn "debug version chosen, profile USE flag ignored."
		fi
	elif use profile ; then
		myconf="--disable-debug --disable-optimize --enable-profile"
		if use optimize ; then
			ewarn "profile version chosen, optimize USE flag ignored."
		fi
	elif use optimize ; then
		myconf="--disable-debug --enable-optimize --disable-profile"
	else
		# optimize is the default anyway
		myconf="--disable-debug --enable-optimize --disable-profile"
	fi

	# add -march=native configure flag if wanted
	if use march-native ; then
		myconf="${myconf} --enable-cpu-specific-optimizations=native"
	fi

	myconf="${myconf} --without-jackasyn \
		$(use_with truetype freetype2) \
		$(use_with wxwidgets wx) \
		$(use_with wxwidgets GTK) \
		$(use_with cegui CEGUI) \
		$(use_with cg Cg) \
		$(use_with cg CgGL) \
		$(use_with alsa asound) \
		$(use_with X x)"
  for myuse in java bullet lcms png jpeg mng perl python vorbis speex 3ds ode cal3d; do
    myconf="${myconf} $(use_with ${myuse})"
  done
  econf ${myconf} || die "configure failed."
}

src_compile() {
	local jamopts=$(echo "${MAKEOPTS}" | sed -ne "/-j/ { s/.*\(-j[[:space:]]*[0-9]\+\).*/\1/; p }")
	jam -q ${jamopts} || die "compile failed (jam -q ${jamopts})"

	if use static-plugins; then
		jam -q ${jamopts} staticplugins \
		|| die "staticplugins compile failed (jam -q ${jamopts})"
	fi

	# No cs-config-2.0 script is ready, but contains some defects that are to be patched away:
	epatch "${FILESDIR}"/${MY_P}-cs-config.patch
}

src_install() {
	for installTarget in bin bindings config data include lib plugin
	do
		jam -q -s DESTDIR="${D}" install_${installTarget} \
			|| die "jam install_${installTarget} failed"
	done

	# install static-plugins if wanted
	if use static-plugins; then
		jam -q -s DESTDIR="${D}" install_staticplugins \
			|| die "jam install_staticplugins failed"
	fi

	# install documentation if wanted
	if use doc; then
		jam -q -s DESTDIR="${D}" install_doc || die "jam install_doc failed"
	fi

	# As the target install_doc uses crystalspace-${MY_PV} as target, but dodoc
	# uses ${PF}, this said var has to be manipulated first.
	local oldPF=${PF}
	PF=${MY_P}
	dodoc README docs/history*
	PF=${oldPF}

	echo "CRYSTAL_PLUGIN=/usr/$(get_libdir)/${MY_P}" > 90crystalspace
	echo "CRYSTAL_CONFIG=/etc/${MY_P}" >> 90crystalspace
  # "CRYSTAL" seems to be an env var that is now important, although it
  # existed already in CS-1.4 and was never actually needed for CS to
  # work properly
	echo "CRYSTAL=/usr/share/${MY_P}" >> 90crystalspace
	doenvd 90crystalspace

	# Applications that do not read CRYSTAL_CONFIG need vfs.cfg in $CRYSTAL:
	dosym /etc/${MY_P}/vfs.cfg /usr/share/${MY_P}/vfs.cfg

	# Applications that do not read CRYSTAL_PLUGIN need the libdir in $CRYSTAL:
	dosym /usr/$(get_libdir)/${MY_P} /usr/share/${MY_P}/libs
}
