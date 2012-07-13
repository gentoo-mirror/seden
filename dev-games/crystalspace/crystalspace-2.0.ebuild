# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit autotools eutils flag-o-matic multilib java-pkg-opt-2 wxwidgets versionator

MY_PV=$(get_version_component_range 1-2)
MY_P=${PN}-${MY_PV}

DESCRIPTION="Portable 3D Game Development Kit written in C++"
HOMEPAGE="http://www.crystalspace3d.org/"
SRC_URI="http://www.crystalspace3d.org/downloads/release/${PN}-src-${MY_PV}.tar.bz2"
RESTRICT="mirror"

LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~x86"
IUSE="3ds alsa bullet cal3d cegui cg debug doc java jpeg lcms mng ode \
      perl png +python static-plugins speex truetype vorbis wxwidgets +X"

SLOT="0"

COMMON_DEP="virtual/opengl
	media-libs/openal
	x11-libs/libXt
	x11-libs/libXxf86vm
	cg? ( media-gfx/nvidia-cg-toolkit )
	ode? ( >=dev-games/ode-0.12 )
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

S=${WORKDIR}/${PN}-src-${MY_PV}

src_prepare() {
	# configure.ac forces /usr/local/lib (and /usr/local/include if present) upon
	# users, which is a bad thing to do. Patch in a check to not do this if the
	# --prefix, --libdir and/or --includedir options lead to default paths.
	epatch "${FILESDIR}"/${MY_P}-01-remove_hardcoded_libpath.patch

	# The maintainers enforce a mode of optimize, profile or debug upon users,
	# enabling all sorts of C[XX]/LDFLAGS which might clash horribly with make.conf.
	# Solution: Path a new mode "custom" in which is activated unless a user sets
	#  the use flag "debug"
	epatch "${FILESDIR}"/${MY_P}-02-add_custom_mode.patch
	epatch "${FILESDIR}"/${MY_P}-03-add_custom_variant.patch

	# Before the new custom mode can be put into action, two additional changes are
	# needed:
	# A) Add two functions to add only content to shell variables that is not present
	#    yet (used on all tries to modify C[XX]/LFLAGS.*), and
	# B) Change configure.ac to NOT dump Jam vars until everything is set.
	# C) Change m4 functions to not dump Jam vars we save and use elsewhere.
	# A:
	epatch "${FILESDIR}"/${MY_P}-04-add_var_trimmer.patch
	# B:
	epatch "${FILESDIR}"/${MY_P}-05-remove_emit_from_configure_ac_01.patch
	epatch "${FILESDIR}"/${MY_P}-06-remove_emit_from_configure_ac_02.patch
	epatch "${FILESDIR}"/${MY_P}-07-remove_emit_from_configure_ac_03.patch
	epatch "${FILESDIR}"/${MY_P}-08-remove_emit_from_configure_ac_04.patch
	epatch "${FILESDIR}"/${MY_P}-09-remove_emit_from_configure_ac_05.patch
	# C:
	epatch "${FILESDIR}"/${MY_P}-10-remove_emit_from_compiler_funcs.patch

	# The new ode version no longer has the StepFast API, so patch this
	# code (experimental anyway) out:
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_01.patch
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_02.patch
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_03.patch
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_04.patch
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_05.patch
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_06.patch
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_07.patch
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_08.patch
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_09.patch
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_10.patch
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_11.patch
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_12.patch
	epatch "${FILESDIR}"/${MY_P}-fix_ode_update_13.patch

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
		myconf="--enable-debug"
	else
		myconf="--enable-custom"
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

	echo "CRYSTAL=/usr/share/${MY_P}" >> 90crystalspace
	echo "CRYSTAL_PLUGIN=/usr/$(get_libdir)/${MY_P}" > 90crystalspace
	echo "CRYSTAL_CONFIG=/etc/${MY_P}" >> 90crystalspace
	doenvd 90crystalspace

	# Applications that do not read CRYSTAL_CONFIG need vfs.cfg in $CRYSTAL:
	dosym /etc/${MY_P}/vfs.cfg /usr/share/${MY_P}/vfs.cfg

	# Applications that do not read CRYSTAL_PLUGIN need the libdir in $CRYSTAL:
	dosym /usr/$(get_libdir)/${MY_P} /usr/share/${MY_P}/libs
}
