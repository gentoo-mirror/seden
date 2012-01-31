# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

KDE_LINGUAS="cs de fr hu pl ru zh_CN"
KDE_MINIMAL="4.8"

inherit kde4-base mercurial

DESCRIPTION="Alternate taskbar KDE plasmoid, similar to Windows 7 - Flupp Fork"
HOMEPAGE="https://bitbucket.org/flupp/smooth-tasks-fork"
EHG_REPO_URI="https://bitbucket.org/flupp/smooth-tasks-fork"
EHG_PROJECT="smooth-tasks-fork"

LICENSE="GPL-2"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

DEPEND="
	$(add_kdebase_dep libtaskmanager)
"
RDEPEND="${DEPEND}
	$(add_kdebase_dep plasma-workspace)
"
