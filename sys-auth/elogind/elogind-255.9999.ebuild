# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

inherit git-r3 linux-info meson pam python-any-r1 udev xdg-utils

DESCRIPTION="The systemd project's logind, extracted to a standalone package"
HOMEPAGE="https://github.com/elogind/elogind"
EGIT_REPO_URI="https://github.com/elogind/elogind.git"
EGIT_BRANCH="v255-stable"
EGIT_SUBMODULES=()

LICENSE="CC0-1.0 LGPL-2.1+ public-domain"
SLOT="0"
KEYWORDS=""
IUSE="+acl audit debug doc efi +pam +policykit selinux"

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
	# Removed -Ddefault-hierarchy=${cgroupmode}
	# -> It is completely irrelevant with -Dcgroup-controller=openrc anyway.
	local emesonargs=(
		$(usex debug "-Ddebug-extra=elogind" "")
		--buildtype $(usex debug debug release)
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		-Dacl=$(usex acl true false)
		-Daudit=$(usex audit true false)
		-Dbashcompletiondir="${EPREFIX}/usr/share/bash-completion/completions"
		-Dcgroup-controller=openrc
		-Ddefault-kill-user-processes=true
		-Ddocdir="${EPREFIX}/usr/share/doc/${PF}"
		-Defi=$(usex efi true false)
		-Dhtml=$(usex doc auto false)
		-Dhtmldir="${EPREFIX}/usr/share/doc/${PF}/html"
		-Dinstall-sysconfdir=true
		-Dman=auto
		-Dmode=release
		-Dpam=$(usex pam true false)
		-Dpamlibdir=$(getpam_mod_dir)
		-Drootlibdir="${EPREFIX}"/$(get_libdir)
		-Drootlibexecdir="${EPREFIX}"/$(get_libdir)/elogind
		-Drootprefix="${EPREFIX}/"
		-Dselinux=$(usex selinux true false)
		-Dsmack=true
		-Dudevrulesdir="$(get_udevdir)"/rules.d
		-Dzshcompletiondir="${EPREFIX}/usr/share/zsh/site-functions"
	)

	meson_src_configure
}

src_install() {
	meson_src_install

	newinitd "${FILESDIR}"/${PN}.init ${PN}

	sed -e "s/@libdir@/$(get_libdir)/" "${FILESDIR}"/${PN}.conf.in > ${PN}.conf || die
	newconfd ${PN}.conf ${PN}
}

pkg_postinst() {
	udev_reload
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

pkg_postrm() {
	udev_reload
}
