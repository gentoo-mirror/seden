# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit subversion

DESCRIPTION="easy way to install DLLs needed to work around problems in Wine"
HOMEPAGE="http://code.google.com/p/winetricks/ http://wiki.winehq.org/winetricks"
ESVN_REPO_URI="http://${PN}.googlecode.com/svn/trunk"
ESVN_PROJECT="${PN}"

LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~x86"
IUSE="gtk kde"

SLOT="0"

DEPEND=""
RDEPEND="
	app-emulation/wine
	gtk? ( gnome-extra/zenity )
	kde? ( kde-base/kdialog )
"

src_install() {
	dobin src/${PN} || die
}
