# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools git-r3 linux-info pam udev

DESCRIPTION="The systemd project's logind, extracted to a standalone package"
HOMEPAGE="https://github.com/elogind/elogind"
EGIT_REPO_URI="https://github.com/elogind/elogind.git"
EGIT_BRANCH="v233-stable"

LICENSE="CC0-1.0 LGPL-2.1+ public-domain"
SLOT="0"
KEYWORDS=""
IUSE="acl debug pam policykit selinux"

RDEPEND="
	sys-apps/util-linux
	sys-libs/libcap
	virtual/libudev:=
	acl? ( sys-apps/acl )
	pam? ( virtual/pam )
	selinux? ( sys-libs/libselinux )
	!sys-apps/systemd
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	dev-util/gperf
	dev-util/intltool
	sys-devel/libtool
	virtual/pkgconfig
"
PDEPEND="
	sys-apps/dbus
	policykit? ( sys-auth/polkit )
"

PATCHES=( "${FILESDIR}/${PN}-226.4-docs.patch" )

pkg_setup() {
	local CONFIG_CHECK="~CGROUPS ~EPOLL ~INOTIFY_USER ~SECURITY_SMACK
		~SIGNALFD ~TIMERFD"

	if use kernel_linux; then
		linux-info_pkg_setup
	fi
}

src_prepare() {
	default
	eautoreconf # Makefile.am patched by "${FILESDIR}/${P}-docs.patch"
}

src_configure() {
	econf \
		--with-pamlibdir=$(getpam_mod_dir) \
		--with-udevrulesdir="$(get_udevdir)"/rules.d \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--with-rootlibdir="${EPREFIX}"/$(get_libdir) \
		--with-rootlibexecdir="${EPREFIX}"/$(get_libdir)/libexec \
		--enable-smack \
		--with-cgroup-controller=openrc \
		--disable-lto \
		$(use_enable debug debug elogind) \
		$(use_enable acl) \
		$(use_enable pam) \
		$(use_enable selinux)
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die

	newinitd "${FILESDIR}"/${PN}.init ${PN}

	sed -e "s/@libdir@/$(get_libdir)/" "${FILESDIR}"/${PN}.conf.in > ${PN}.conf || die
	newconfd ${PN}.conf ${PN}
}

pkg_postinst() {
	if [ "$(rc-config list boot | grep elogind)" = "" ]; then
		ewarn "To enable the elogind daemon, elogind must be"
		ewarn "added to the boot runlevel:"
		ewarn "# rc-update add elogind boot"
	fi
}
