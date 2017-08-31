# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 linux-info meson pam udev

DESCRIPTION="The systemd project's logind, extracted to a standalone package"
HOMEPAGE="https://github.com/elogind/elogind"
EGIT_REPO_URI="https://github.com/elogind/elogind.git"
EGIT_BRANCH="master"

LICENSE="CC0-1.0 LGPL-2.1+ public-domain"
SLOT="0"
KEYWORDS=""
IUSE="+acl debug doc +pam +policykit selinux"

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
	>=dev-util/meson-0.41.0
	>=dev-util/ninja-1.7.2
	virtual/pkgconfig
"
PDEPEND="
	sys-apps/dbus
	policykit? ( sys-auth/polkit )
"

pkg_setup() {
	local CONFIG_CHECK="~CGROUPS ~EPOLL ~INOTIFY_USER ~SECURITY_SMACK
		~SIGNALFD ~TIMERFD"

	if use kernel_linux; then
		linux-info_pkg_setup
	fi
}

src_configure() {
	local emesonargs
	emesonargs=(
		-Ddocdir="${EPREFIX}/usr/share/doc/${P}" \
		-Dhtmldir="${EPREFIX}/usr/share/doc/${P}/html" \
		-Dpamlibdir=$(getpam_mod_dir) \
		-Dudevrulesdir="$(get_udevdir)"/rules.d \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		-Drootlibdir="${EPREFIX}"/$(get_libdir) \
		-Drootlibexecdir="${EPREFIX}"/$(get_libdir)/elogind \
		-Drootprefix="/" \
		-Dsmack=true \
		-Dman=auto \
		-Dhtml=$(usex doc auto false) \
		-Dcgroup-controller=openrc \
		-Ddefault-hierarchy=legacy \
		-Ddebug=$(usex debug elogind false) \
		--buildtype $(usex debug debug release) \
		-Dacl=$(usex acl true false) \
		-Dpam=$(usex pam true false) \
		-Dselinux=$(usex selinux true false)
		-Dbashcompletiondir="${EPREFIX}/usr/share/bash-completion/completions" \
		-Dzsh-completion="${EPREFIX}/usr/share/zsh/site-functions" \
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	
	newinitd "${FILESDIR}"/${PN}-235.init ${PN}

	sed -e "s/@libdir@/$(get_libdir)/" "${FILESDIR}"/${PN}-235.conf.in > ${PN}.conf || die
	newconfd ${PN}.conf ${PN}
}

pkg_postinst() {
	if [ "$(rc-config list boot | grep elogind)" = "" ]; then
		ewarn "To enable the elogind daemon, elogind must be"
		ewarn "added to the boot runlevel:"
		ewarn "# rc-update add elogind boot"
	fi
}
