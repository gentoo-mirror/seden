# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

if [[ ${PV} = *9999* ]]; then
	EGIT_BRANCH="v252-stable"
	EGIT_REPO_URI="https://github.com/elogind/elogind.git"
	inherit git-r3
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~loong ~mips ppc ppc64 ~riscv ~s390 sparc x86"
fi

inherit linux-info meson pam python-any-r1 udev xdg-utils

DESCRIPTION="The systemd project's logind, extracted to a standalone package"
HOMEPAGE="https://github.com/elogind/elogind"

LICENSE="CC0-1.0 LGPL-2.1+ public-domain"
SLOT="0"
IUSE="+acl audit +cgroup-hybrid debug doc +pam +policykit selinux test"
RESTRICT="!test? ( test )"

BDEPEND="
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	dev-util/gperf
	virtual/pkgconfig
"
DEPEND="
	audit? ( sys-process/audit )
	sys-apps/util-linux
	sys-libs/libcap
	virtual/libudev:=
	acl? ( sys-apps/acl )
	pam? ( sys-libs/pam )
	selinux? ( sys-libs/libselinux )
"
RDEPEND="${DEPEND}
	!sys-apps/systemd
"
PDEPEND="
	sys-apps/dbus
	policykit? ( sys-auth/polkit )
"

DOCS=( README.md )

PATCHES=(
	"${FILESDIR}/${PN}-252-docs.patch"
)

python_check_deps() {
	python_has_version "dev-python/jinja[${PYTHON_USEDEP}]" &&
	python_has_version "dev-python/lxml[${PYTHON_USEDEP}]"
}

pkg_setup() {
	local CONFIG_CHECK="~CGROUPS ~EPOLL ~INOTIFY_USER ~SIGNALFD ~TIMERFD"

	use kernel_linux && linux-info_pkg_setup
}

src_prepare() {
	default
	xdg_environment_reset
}

src_configure() {
	if use cgroup-hybrid; then
		cgroupmode="hybrid"
	else
		cgroupmode="unified"
	fi

	python_setup

	local emesonargs=(
		$(usex debug "-Ddebug-extra=elogind" "")
		--buildtype $(usex debug debug release)
		-Ddocdir="${EPREFIX}/usr/share/doc/${PF}"
		-Dhtmldir="${EPREFIX}/usr/share/doc/${PF}/html"
		-Dpamlibdir=$(getpam_mod_dir)
		-Dudevrulesdir="${EPREFIX}$(get_udevdir)"/rules.d
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		-Drootlibdir="${EPREFIX}"/$(get_libdir)
		-Drootlibexecdir="${EPREFIX}"/$(get_libdir)/elogind
		-Drootprefix="${EPREFIX}/"
		-Dbashcompletiondir="${EPREFIX}/usr/share/bash-completion/completions"
		-Dzshcompletiondir="${EPREFIX}/usr/share/zsh/site-functions"
		-Dacl=$(usex acl true false)
		-Daudit=$(usex audit true false)
		-Dcgroup-controller=openrc
		-Ddefault-hierarchy=${cgroupmode}
		-Ddefault-kill-user-processes=false
		-Dhtml=$(usex doc auto false)
		-Dinstall-sysconfdir=true
		-Dman=auto
		-Dmode=release
		-Dpam=$(usex pam true false)
		-Dselinux=$(usex selinux true false)
		-Dsmack=true
		-Dtests=$(usex test true false)
		-Dutmp=$(usex elibc_musl false true)
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	newinitd "${FILESDIR}"/${PN}.init ${PN}

	sed -e "s|@libdir@|$(get_libdir)|" "${FILESDIR}"/${PN}.conf.in > ${PN}.conf || die
	newconfd ${PN}.conf ${PN}
}

pkg_postinst() {
	udev_reload
	if ! use pam; then
		ewarn "${PN} will not be managing user logins/seats without USE=\"pam\"!"
		ewarn "In other words, it will be useless for most applications."
		ewarn
	fi
	if ! use policykit; then
		ewarn "loginctl will not be able to perform privileged operations without"
		ewarn "USE=\"policykit\"! That means e.g. no suspend or hibernate."
		ewarn
	fi
	if [[ "$(rc-config list boot | grep elogind)" != "" ]]; then
		elog "elogind is currently started from boot runlevel."
	elif [[ "$(rc-config list default | grep elogind)" != "" ]]; then
		ewarn "elogind is currently started from default runlevel."
		ewarn "Please remove elogind from the default runlevel and"
		ewarn "add it to the boot runlevel by:"
		ewarn "# rc-update del elogind default"
		ewarn "# rc-update add elogind boot"
	else
		elog "elogind is currently not started from any runlevel."
		elog "You may add it to the boot runlevel by:"
		elog "# rc-update add elogind boot"
		elog
		elog "Alternatively, you can leave elogind out of any"
		elog "runlevel. It will then be started automatically"
		if use pam; then
			elog "when the first service calls it via dbus, or"
			elog "the first user logs into the system."
		else
			elog "when the first service calls it via dbus."
		fi
	fi

	for version in ${REPLACING_VERSIONS}; do
		if ver_test "${version}" -lt 252.9; then
			elog "Starting with release 252.9 the sleep configuration is now done"
			elog "in the /etc/elogind/sleep.conf. Should you use non-default sleep"
			elog "configuration remember to migrate those to new configuration file."
		fi
	done
}

pkg_postrm() {
	udev_reload
}

