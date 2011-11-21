# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: net-mail/davmail-3.9.1 $

EAPI="3"
inherit eutils

MY_REV="1843"
MY_PN="davmail"
MY_P_A="${MY_PN}-linux-x86"
MY_P_B="${PV}-${MY_REV}"
SRC_URI="x86? (
                 mirror://sourceforge/${MY_PN}/${MY_P_A}-${MY_P_B}.tgz
              )
       amd64? (
                 mirror://sourceforge/${MY_PN}/${MY_P_A}_64-${MY_P_B}.tgz
              )"
DESCRIPTION="POP/IMAP/SMTP/Caldav/Carddav/LDAP Exchange Gateway"
HOMEPAGE="http://davmail.sourceforge.net/"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="menu server"

DEPEND="|| ( virtual/jre:1.6 virtual/jdk:1.6 )
  !net-mail/davmail"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use server ; then
		enewuser davmail -1 -1 /dev/null
	fi
}

src_install() {
	cd "${S}"
	# Fix the script BASE=
	sed -i -e "s@BASE=.*@BASE=/opt/davmail@" davmail.sh
	dodir "/opt/$MY_PN"
	cp -a * "${D}/opt/$MY_PN"
	dodir "/opt/bin"
	dosym "/opt/$MY_PN/davmail.sh" "/opt/bin/davmail.sh"

	if use menu; then
		domenu "${FILESDIR}"/davmail.desktop
		doicon "${FILESDIR}"/davmail.png
	fi

	if use server ; then
		insinto /etc
		doins "${FILESDIR}"/davmail.properties
		newinitd "${FILESDIR}"/davmail.init davmail
		newconfd "${FILESDIR}"/davmail.confd davmail
	fi
}

pkg_postinst() {
	if use server ; then
		elog "You have chosen to run davmail as a system service."
		elog "You will need to modify /etc/davmail.properties"
		elog "to service your needs. You may find it easier to"
		elog "run the davmail.sh, configure it via the GUI and"
		elog "copy the resulting ~/.davmail.properties to /etc."
	fi
}

