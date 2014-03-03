# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/taskcoach/taskcoach-1.3.32-r1.ebuild,v 1.1 2013/09/09 17:54:05 ago Exp $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1 eutils

MY_PN="TaskCoach"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Simple personal tasks and todo lists manager"
HOMEPAGE="http://www.taskcoach.org http://pypi.python.org/pypi/TaskCoach"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
RESTRICT="mirror"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="libnotify"
DEPEND=">=dev-python/wxpython-2.8.9.2:2.8[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
	libnotify? ( dev-python/notify-python[${PYTHON_USEDEP}] )"

S="${WORKDIR}/${MY_P}"

DOCS=( CHANGES.txt README.txt )

python_install_all() {
	distutils-r1_python_install_all
	doicon "icons.in/${PN}.png"
	mv -f "${D}/usr/bin/${PN}.py" "${D}/usr/bin/${PN}"
	make_desktop_entry ${PN} "Task Coach" ${PN} Office
}
