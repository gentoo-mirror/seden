# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools git-r3 multilib readme.gentoo-r1 systemd user

DESCRIPTION="Service providing elegant and stable means of managing Optimus graphics chipsets"
HOMEPAGE="http://bumblebee-project.org https://github.com/Bumblebee-Project/Bumblebee"

EGIT_MIN_CLONE_TYPE="shallow"
EGIT_REPO_URI="https://github.com/Bumblebee-Project/${PN/bu/Bu}.git"
EGIT_BRANCH="develop"
SRC_URI=""

SLOT="0"
LICENSE="GPL-3"
KEYWORDS=""

IUSE="+bbswitch video_cards_nouveau video_cards_nvidia"

COMMON_DEPEND="
	dev-libs/glib:2
	dev-libs/libbsd
	sys-apps/kmod
	x11-libs/libX11
"

RDEPEND="${COMMON_DEPEND}
	virtual/opengl
	x11-base/xorg-drivers[video_cards_nvidia?,video_cards_nouveau?]
	bbswitch? ( sys-power/bbswitch )
"

DEPEND="${COMMON_DEPEND}
	sys-apps/help2man
	virtual/pkgconfig
"

PDEPEND="
	|| (
		x11-misc/primus
		x11-misc/virtualgl
	)
"

REQUIRED_USE="|| ( video_cards_nouveau video_cards_nvidia )"

PATCHES=(
	"${FILESDIR}"/nvidia-uvm-support.patch
)

pkg_setup() {
	enewgroup bumblebee
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	if use video_cards_nvidia ; then
		# Get paths to GL libs for all ABIs
		local i nvlib=""
		for i in  $(get_all_libdirs) ; do
			nvlib="${nvlib}:/usr/${i}/opengl/nvidia/lib"
		done

		local nvpref="/usr/$(get_libdir)/opengl/nvidia"
		local xorgpref="/usr/$(get_libdir)/xorg/modules"
		ECONF_PARAMS="CONF_DRIVER=nvidia CONF_DRIVER_MODULE_NVIDIA=nvidia-uvm \
			CONF_LDPATH_NVIDIA=${nvlib#:} \
			CONF_MODPATH_NVIDIA=${nvpref}/lib,${nvpref}/extensions,${xorgpref}/drivers,${xorgpref}"
	fi

	econf \
		${ECONF_PARAMS}
}

src_install() {
	default

	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newenvd "${FILESDIR}"/${PN}.envd 99${PN}
	systemd_dounit scripts/systemd/bumblebeed.service

	local DOC_CONTENTS="In order to use Bumblebee, add your user to 'bumblebee' group.
		You may need to setup your /etc/bumblebee/bumblebee.conf"
	readme.gentoo_create_doc
}
