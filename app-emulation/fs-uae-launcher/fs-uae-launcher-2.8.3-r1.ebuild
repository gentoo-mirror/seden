# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{4,5,6} )

inherit eutils gnome2-utils python-r1

DESCRIPTION="PyQT5 based Launcher for FS-UAE."
HOMEPAGE="https://fs-uae.net/"
SRC_URI="https://fs-uae.net/stable/${PV}/${P}.tar.gz"
LICENSE="GPL-2"
KEYWORDS="amd64 x86"
SLOT="0"
IUSE=""

RDEPEND="
	${PYTHON_DEPS}
	app-emulation/fs-uae
	dev-python/PyQt5
"

DEPEND="${RDEPEND}
"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
"

PATCHES=(
	"${FILESDIR}"/${P}-Makefile.patch
	"${FILESDIR}"/${P}-German-ROMs.patch
)

DOCS=( COPYING README )

src_compile() {
	emake PREFIX="${EPREFIX}/usr"
}

src_install() {
	einstalldocs
	emake install PREFIX="${EPREFIX}/usr" DESTDIR="${D}"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update

	elog "Some important information:"
	elog
	elog " - By default, FS-UAE creates its directories under"
	elog "   Documents/FS-UAE. If your Documents directory is not"
	elog "   configured according to the XDG user dir spec, ~/FS-UAE"
	elog "   will be used as a fallback."
	elog
	elog " - You can override this by putting the path to the desired base"
	elog "   directory in a special config file. The config file will be"
	elog "   read by both FS-UAE and FS-UAE Launcher if it exists:"
	elog "     ~/.config/fs-uae/base-dir"
	elog "   Alternatively, you can start FS-UAE and/or FS-UAE Launcher"
	elog "   with --base-dir=/path/to/desired/dir"
}

pkg_postrm() {
	gnome2_icon_cache_update
}
