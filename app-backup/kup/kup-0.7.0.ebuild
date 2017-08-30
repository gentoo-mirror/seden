# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

KDE_HANDBOOK="forceoptional"
inherit kde5

DESCRIPTION="A backup scheduler for KDE's Plasma desktop"
HOMEPAGE="https://www.linux-apps.com/p/1127689"
SRC_URI="https://github.com/spersson/${PN^}/archive/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="amd64 x86"
IUSE=""

CDEPEND="
	$(add_frameworks_dep kcoreaddons)
	$(add_frameworks_dep kdbusaddons)
	$(add_frameworks_dep ki18n)
	$(add_frameworks_dep kio)
	$(add_frameworks_dep solid)
	$(add_frameworks_dep kidletime)
	$(add_frameworks_dep knotifications)
	$(add_frameworks_dep kiconthemes)
	$(add_frameworks_dep kconfig)
	$(add_frameworks_dep kinit)
	$(add_frameworks_dep kjobwidgets)
	$(add_qt_dep qtgui)
	$(add_qt_dep qtwidgets)
	app-backup/bup
	net-misc/rsync
"
DEPEND="${CDEPEND}
	x11-misc/shared-mime-info
"
RDEPEND="${CDEPEND}"
