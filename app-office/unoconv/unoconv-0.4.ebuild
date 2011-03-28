# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils

DESCRIPTION="Convert between any document format supported by OpenOffice"
HOMEPAGE="http://dag.wieers.com/home-made/unoconv/"
SRC_URI="http://dag.wieers.com/home-made/unoconv/${P}.tar.bz2"
LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
IUSE=""

SLOT="0"

RDEPEND=">=dev-lang/python-2.5
	 || ( app-office/openoffice app-office/openoffice-bin )"
DEPEND="dev-python/setuptools
        >=app-text/asciidoc-8.2.6"

src_install() {
	emake docs DESTDIR="${D}"
	emake docs-install DESTDIR="${D}"
	emake install DESTDIR="${D}"
	emake install-links DESTDIR="${D}"
}
