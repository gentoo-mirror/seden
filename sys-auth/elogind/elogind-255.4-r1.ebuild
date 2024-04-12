# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

if [[ ${PV} = *9999* ]]; then
	EGIT_BRANCH="v255-stable"
	EGIT_REPO_URI="https://github.com/elogind/elogind.git"
	EGIT_SUBMODULES=()
	inherit git-r3
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}-r1.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
	S="${WORKDIR}/${PN}-${PV}-r1"
fi

inherit linux-info meson pam python-any-r1 udev xdg-utils

DESCRIPTION="The systemd project's logind, extracted to a standalone package"
HOMEPAGE="https://github.com/elogind/elogind"

LICENSE="CC0-1.0 LGPL-2.1+ public-domain"
SLOT="0"
IUSE="+acl audit debug doc +pam +policykit selinux test"
RESTRICT="!test? ( test )"

BDEPEND="
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	dev-util/gperf
	virtual/pkgconfig
	$(python_gen_any_dep 'dev-python/jinja[${PYTHON_USEDEP}]')
	$(python_gen_any_dep 'dev-python/lxml[${PYTHON_USEDEP}]')
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
	python_setup

	# Removed -Ddefault-hierarchy=${cgroupmode}
	# -> It is completely irrelevant with "-Dcgroup-controller=openrc".
	local emesonargs=(
		$(usex debug "-Ddebug-extra=elogind" "")
		-Dbuildtype=$(usex debug debug release)
		--prefix="${EPREFIX}/usr"
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		--libexecdir="${EPREFIX}"/$(get_libdir)/elogind
		--localstatedir="${EPREFIX}"/var
		--sysconfdir="${EPREFIX}"/etc
		-Ddocdir="${EPREFIX}/usr/share/doc/${PF}"
		-Dhtmldir="${EPREFIX}/usr/share/doc/${PF}/html"
		-Ddbuspolicydir="${EPREFIX}"/usr/share/dbus-1/system.d
		-Ddbussystemservicedir="${EPREFIX}"/usr/share/dbus-1/system-services
		-Dpamlibdir=$(getpam_mod_dir)
		-Dudevrulesdir="${EPREFIX}$(get_udevdir)"/rules.d
		-Dbashcompletiondir="${EPREFIX}/usr/share/bash-completion/completions"
		-Dzshcompletiondir="${EPREFIX}/usr/share/zsh/site-functions"
		-Dacl=$(usex acl enabled disabled)
		-Daudit=$(usex audit enabled disabled)
		-Dcgroup-controller=openrc
		-Ddefault-kill-user-processes=true
		-Defi=false
		-Dhtml=$(usex doc auto disabled)
		-Dinstall-sysconfdir=true
		-Dman=auto
		-Dmode=release
		-Dpam=$(usex pam enabled disabled)
		-Dselinux=$(usex selinux enabled disabled)
		-Dsmack=true
		-Dtests=$(usex test true false)
		-Dutmp=$(usex elibc_musl false true)
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	keepdir /var/lib/elogind
	newinitd "${FILESDIR}"/${PN}.init ${PN}

	sed -e "s/@libdir@/$(get_libdir)/" "${FILESDIR}"/${PN}.conf.in > ${PN}.conf || die
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
	fi
	elog
	elog "Alternatively, you can leave elogind out of any"
	elog "runlevel. It will then be started automatically"
	if use pam; then
		elog "when the first service calls it via dbus, or"
		elog "the first user logs into the system."
	else
		elog "when the first service calls it via dbus."
	fi

	for version in ${REPLACING_VERSIONS}; do
		if ver_test "${version}" -lt 252.9; then
			elog "Starting with release 255.4 the sleep configuration is now done"
			elog "in the /etc/elogind/sleep.conf while the elogind additions have"
			elog "been moved to /etc/elogind/sleep.conf.d/10-elogind.conf."
			elog "Should you use non-default sleep configuration remember to migrate"
			elog "those to a new configuration file in /etc/elogind/sleep.conf.d/."
		fi
	done
}

pkg_postrm() {
	udev_reload
}
