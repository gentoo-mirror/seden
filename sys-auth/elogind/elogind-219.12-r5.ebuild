# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit autotools eutils linux-info pam udev

DESCRIPTION="The systemd project's logind, extracted to a standalone package"
HOMEPAGE="https://github.com/wingo/elogind"
SRC_URI="https://github.com/wingo/elogind/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CC0-1.0 LGPL-2.1+ public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="acl apparmor pam policykit selinux +seccomp"

COMMON_DEPEND="
	sys-libs/libcap
	sys-apps/util-linux
	virtual/libudev:=
	acl? ( sys-apps/acl )
	apparmor? ( sys-libs/libapparmor )
	pam? ( virtual/pam )
	seccomp? ( sys-libs/libseccomp )
	selinux? ( sys-libs/libselinux )
"
RDEPEND="${COMMON_DEPEND}
	sys-apps/dbus
	policykit? ( sys-auth/polkit )
	!sys-auth/systemd
"
DEPEND="${COMMON_DEPEND}
	dev-util/gperf
	dev-util/intltool
	sys-devel/libtool
	virtual/pkgconfig
"

DOCS=( NEWS README TODO )
PATCHES=(
	"${FILESDIR}/${PN}-docs.patch"
	"${FILESDIR}/${PN}-lrt.patch"
	"${FILESDIR}/${P}-session.patch"
	"${FILESDIR}/${PN}-add_missing_login1_permissions.patch"
)


pkg_setup() {
	if use kernel_linux; then
		linux-info_pkg_setup
		if ! linux_config_exists; then
			ewarn "Can't check the linux kernel configuration."
		else
			local missing_count=0
			if linux_chkconfig_present AUDIT; then
				ewarn "AUDIT is eabled. If you have problems with the auditing"
				ewarn "  system creating and closing sessions, then disable it."
			fi
			if ! linux_chkconfig_present CGROUPS; then
				eerror "CGROUPS is not enabled but needed by elogind."
				eerror " (it is OK to disable all controllers)"
				missing_count=$((missing_count+1))
			fi
			if ! linux_chkconfig_present INOTIFY_USER; then
				eerror "INOTIFY_USER is not enabled but needed by elogind."
				missing_count=$((missing_count+1))
			fi
			if ! linux_chkconfig_present SIGNALFD; then
				eerror "SIGNALFD is not enabled but needed by elogind."
				missing_count=$((missing_count+1))
			fi
			if ! linux_chkconfig_present TIMERFD; then
				eerror "TIMERFD is not enabled but needed by elogind."
				missing_count=$((missing_count+1))
			fi
			if ! linux_chkconfig_present EPOLL; then
				eerror "EPOLL is not enabled but needed by elogind."
				missing_count=$((missing_count+1))
			fi
			if ! linux_chkconfig_present SECCOMP; then
				einfo "SECCOMP is not enabled but useful to elogind."
			fi
			[ 0 -lt $missing_count ] && die "$missing_count required kernel features are missing."
		fi
	fi
}

src_prepare() {
	default

	# launch elogind when called via dbus
	sed -i -e "s|/bin/false|/usr/libexec/elogind/elogind|" src/login/org.freedesktop.login1.service || die

	eautoreconf
}

src_configure() {
	local use_smack="--disable-smack"
	if linux_config_exists && linux_chkconfig_present SECURITY_SMACK; then
		use_smack="--enable-smack"
	fi

	econf \
		--with-pamlibdir=$(getpam_mod_dir) \
		--with-udevrulesdir="$(get_udevdir)"/rules.d \
		$(use_enable acl) \
		$(use_enable apparmor) \
		$(use_enable pam) \
		$(use_enable seccomp) \
		$(use_enable selinux) \
		$use_smack
}

src_install() {
	default
	prune_libtool_files --modules
}
