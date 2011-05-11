# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit autotools eutils flag-o-matic multilib java-pkg-opt-2 subversion wxwidgets versionator

MY_PV=$(get_version_component_range 1-2)
MY_P=${PN}-${MY_PV}

DESCRIPTION="Portable 3D Game Development Kit written in C++"
HOMEPAGE="http://www.crystalspace3d.org/"
ESVN_REPO_URI="https://crystal.svn.sourceforge.net/svnroot/crystal/CS/trunk"

LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~x86"
IUSE="3ds alsa bullet cal3d cegui cg debug doc java jpeg mng ode +optimize \
      png profile python static-plugins speex truetype vorbis wxwidgets"

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

S=${WORKDIR}/${MY_P}


src_prepare() {
	# As flags are managed by debug, optimize and profile USE flags,
	# they need to be stripped first. If we do not do this, the calling
	# lines grow so large, that jam segfaults.
	strip-flags

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
		ewarn "optimize is the CS default and thus chosen."
	fi

	myconf="${myconf} --without-lcms --without-jackasyn \
		--with-x --with-mesa --disable-make-emulation --without-perl \
		--with-python --disable-separate-debug-info \
		--disable-optimize-mode-debug-info \
		$(use_with truetype freetype2) \
		$(use_with wxwidgets wx) \
		$(use_with wxwidgets GTK) \
		$(use_with cegui CEGUI) \
		$(use_with cg Cg) \
		$(use_with alsa asound) "
  for myuse in java bullet png jpeg mng vorbis speex 3ds ode cal3d; do
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
}

src_install() {
	for installTarget in bin bindings config data include lib plugin
	do
		jam -q -s DESTDIR="${D}" install_${installTarget} \
			|| die "jam install_${installTarget} failed"
	done
	if use static-plugins; then
		jam -q -s DESTDIR="${D}" install_staticplugins \
			|| die "jam install_staticplugins failed"
	fi
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
  # "CRYSTAL" seems to be an env var that is now important, althoug it
  # existed already in CS-1.4 and was never actually needed for CS to
  # work properly
	echo "CRYSTAL=/usr/share/${MY_P}" >> 90crystalspace
	doenvd 90crystalspace
}

pkg_postinst() {
	elog "Examples coming with this package, need correct light calculation"
	elog "Do the following commands, with the root account, to fix that:"
	# Fill cache directory for the examples
  # Update in 2.1-r1: Let's give users a "ready to use" loop instead 
  # single commands:
	elog "for map in castle isomap parallaxtest r3dtest stenciltest terrain terrainf ; do"
  # new in 2.1: Thanks to the CRYSTAL env var, the path to the maps does
  # not need to be given. As a matter of fact it is important to *not*
  # use the map name with a full path.
	elog "  lighter2 --simpletui ${map}"
	elog "done"
}
