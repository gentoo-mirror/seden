# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit perl-module

MY_PV=$(ver_rs 2 '_' )

DESCRIPTION="Oracle database driver for the DBI module"
SRC_URI="https://github.com/perl5-dbi/${PN}/archive/refs/tags/v${MY_PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${MY_PV}"

LICENSE="|| ( Artistic GPL-1 GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="dev-perl/DBI
	dev-lang/perl
	dev-db/oracle-instantclient"
RDEPEND="$DEPEND"
