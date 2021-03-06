# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic git-r3 linux-info meson pam udev xdg-utils

DESCRIPTION="The systemd project's logind, extracted to a standalone package"
HOMEPAGE="https://github.com/elogind/elogind"
EGIT_REPO_URI="https://github.com/elogind/elogind.git"
EGIT_BRANCH="v241-stable"
EGIT_SUBMODULES=()

LICENSE="CC0-1.0 LGPL-2.1+ public-domain"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="+acl debug doc +pam +policykit selinux"

COMMON_DEPEND="
	sys-apps/util-linux
	sys-libs/libcap
	virtual/libudev:=
	acl? ( sys-apps/acl )
	pam? ( sys-libs/pam )
	selinux? ( sys-libs/libselinux )
"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	dev-util/gperf
	dev-util/intltool
	sys-devel/libtool
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	!sys-apps/systemd
"
PDEPEND="
	sys-apps/dbus
	policykit? ( sys-auth/polkit )
"

PATCHES=(
	"${FILESDIR}/${PN}-241.1-docs.patch"
)

pkg_setup() {
	local CONFIG_CHECK="~CGROUPS ~EPOLL ~INOTIFY_USER ~SIGNALFD ~TIMERFD"

	if use kernel_linux; then
		linux-info_pkg_setup
	fi
}

src_prepare() {
	default
	xdg_environment_reset
}

src_configure() {
	local rccgroupmode="$(grep rc_cgroup_mode /etc/rc.conf | cut -d '"' -f 2)"
	local cgroupmode="legacy"
	local debugmode=""

	if [[ "xhybrid" = "x${rccgroupmode}" ]]; then
		cgroupmode="hybrid"
	elif [[ "xunified" = "x${rccgroupmode}" ]]; then
		cgroupmode="unified"
	fi

	if use debug; then
		debugmode="-Ddebug-extra=elogind"
	fi

	# Duplicating C[XX]FLAGS in LDFLAGS is deprecated and will become
	# a hard error in future meson versions:
	filter-ldflags $CFLAGS $CXXFLAGS

	local emesonargs=(
		-Ddocdir="${EPREFIX}/usr/share/doc/${PF}"
		-Dhtmldir="${EPREFIX}/usr/share/doc/${PF}/html"
		-Dpamlibdir=$(getpam_mod_dir)
		-Dudevrulesdir="$(get_udevdir)"/rules.d
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		-Drootlibdir="${EPREFIX}"/$(get_libdir)
		-Drootlibexecdir="${EPREFIX}"/$(get_libdir)/elogind
		-Drootprefix="${EPREFIX}/"
		-Dbashcompletiondir="${EPREFIX}/usr/share/bash-completion/completions"
		-Dzshcompletiondir="${EPREFIX}/usr/share/zsh/site-functions"
		-Dman=auto
		-Dsmack=true
		-Dcgroup-controller=openrc
		-Ddefault-hierarchy=${cgroupmode}
		-Ddefault-kill-user-processes=false
		-Dacl=$(usex acl true false)
		--buildtype $(usex debug debug release)
		-Dhtml=$(usex doc auto false)
		-Dpam=$(usex pam true false)
		-Dselinux=$(usex selinux true false)
		$debugmode
	)

	meson_src_configure
}

src_install() {
	DOCS+=( src/libelogind/sd-bus/GVARIANT-SERIALIZATION )

	meson_src_install

	newinitd "${FILESDIR}"/${PN}.init ${PN}

	sed -e "s/@libdir@/$(get_libdir)/" "${FILESDIR}"/${PN}.conf.in > ${PN}.conf || die
	newconfd ${PN}.conf ${PN}
}

pkg_postinst() {
	if [[ "$(rc-config list boot | grep elogind)" != "" ]]; then
		elog "elogind is currently started from boot runlevel."
	elif [[ "$(rc-config list default | grep elogind)" != "" ]]; then
		ewarn "elogind is currently started from default runlevel."
		ewarn "Please remove elogind from the default runlevel and"
		ewarn "add it to the boot runlevel by:"
		ewarn "# rc-update del elogind default"
		ewarn "# rc-update add elogind boot"
	else
		ewarn "elogind is currently not started from any runlevel."
		ewarn "You may add it to the boot runlevel by:"
		ewarn "# rc-update add elogind boot"
	fi
}
