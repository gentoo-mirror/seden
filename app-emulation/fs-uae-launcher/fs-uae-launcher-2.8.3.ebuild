# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{4,5,6} )

inherit eutils

DESCRIPTION="PyQT5 based Launcher for FS-UAE."
HOMEPAGE="https://fs-uae.net/"
SRC_URI="https://fs-uae.net/stable/${PV}/${P}.tar.gz"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
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

src_prepare() {
	sed -i -e "s,DESTDIR :=,DESTDIR := ${D}," Makefile || die 'sed DESTDIR failed'
	sed -i -e "s,prefix := /usr/local,prefix := /usr," Makefile || die 'sed prefix failed'
	sed -i -e "s,doc/fs-uae-launcher,doc/${P},g" Makefile || die 'sed doc failed'
	default
}
