# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MODULE_AUTHOR="MJEVANS"
MODULE_VERSION="1.80"
MODULE_DIRECTORY="${MODULE_AUTHOR:0:1}/${MODULE_AUTHOR:0:2}"

inherit perl-module

SRC_URI="mirror://cpan/authors/id/${MODULE_DIRECTORY}/${MODULE_AUTHOR}/${P}.tar.gz"
DESCRIPTION="Oracle database driver for the DBI module"

LICENSE="|| ( Artistic GPL-1 GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-perl/DBI
	dev-lang/perl
	dev-db/oracle-instantclient"
RDEPEND="$DEPEND"
