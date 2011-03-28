# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
inherit eutils

use x86 && MY_P="${PN}-linux-x86-${PV/_p/-}"
use amd64 && MY_P="${PN}-linux-x86_64-${PV/_p/-}"

DESCRIPTION="POP/IMAP/SMTP/Caldav/Carddav/LDAP Exchange Gateway"
HOMEPAGE="http://davmail.sourceforge.net/"
SRC_URI="mirror://sourceforge/davmail/${MY_P}.tgz"
RESTRICT="mirror"

LICENSE="GPL-2"
KEYWORDS="-* ~amd64 ~x86"
IUSE="menu"

SLOT="0"

DEPEND="|| ( virtual/jre:1.6 virtual/jdk:1.6 )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_install() {
   cd "${S}"
   # Fix the script BASE=
   sed -i -e "s@BASE=.*@BASE=/opt/davmail@" davmail.sh

   dodir "/opt/$PN"
   cp -a * "${D}/opt/$PN"
   dodir "/opt/bin"
   dosym "/opt/$PN/davmail.sh" "/opt/bin/davmail.sh"

	if use menu; then
		domenu "${FILESDIR}/davmail.desktop"
		doicon "${FILESDIR}/davmail.png"
	fi
}
