# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils webapp depend.php

DESCRIPTION="dotProject is a PHP web-based project management framework"
HOMEPAGE="http://www.dotproject.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
RESTRICT="mirror"

WEBAPP_MANUAL_SLOT="yes"
SLOT="2.1.5"

KEYWORDS="~amd64 ~ppc ~sparc ~x86"
LICENSE="GPL-2"
IUSE="sendmail unicode"

DEPEND=""
RDEPEND="
	>=app-text/poppler-0.12.3-r3[utils]
	>=www-servers/apache-2.0.49
	unicode?  ( >=dev-lang/php-5.0[gd,unicode,xml] )
	!unicode? ( >=dev-lang/php-5.0[gd,xml] )
	>=dev-db/mysql-5.1
	>=dev-php/jpgraph-2.3
	sendmail? ( mail-mta/sendmail )
"

need_httpd_cgi
need_php_httpd

S=${WORKDIR}/${PN}

src_install () {
	# remove dead links from the archive
	rm -rf ${S}/locales/es
	rm -rf ${S}/locales/pt_br

	# and add the missing temp directory
	[ -e ${S}/files/temp ] || mkdir -p ${S}/files/temp

	webapp_src_preinst

	dodoc ChangeLog README
	rm -f ChangeLog README

	mv includes/config{-dist,}.php

	insinto "${MY_HTDOCSDIR}"
	doins -r .

	webapp_serverowned "${MY_HTDOCSDIR}"/includes/config.php
	webapp_serverowned "${MY_HTDOCSDIR}"/files{,/temp}
	webapp_serverowned "${MY_HTDOCSDIR}"/locales/en

	webapp_postinst_txt en "${FILESDIR}"/install-en.txt
	webapp_src_install
}
