# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="FastTracker 2 inspired music tracker"
HOMEPAGE="http://milkytracker.org/"

EGIT_MIN_CLONE_TYPE="shallow"
EGIT_REPO_URI="https://github.com/${PN}/MilkyTracker.git"
EGIT_BRANCH="master"
SRC_URI=""

LICENSE="|| ( GPL-3 MPL-1.1 ) AIFFWriter.m BSD GPL-3 GPL-3+ LGPL-2.1+ MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="alsa jack"

RDEPEND=">=media-libs/libsdl-1.2:=[X]
	sys-libs/zlib:=
	alsa? ( media-libs/alsa-lib:= )
	jack? ( media-sound/jack-audio-connection-kit:= )"
DEPEND="${RDEPEND}
	>=dev-util/cmake-2.8.12
"

PATCHES=(
        "${FILESDIR}"/${P}-fix-docs.patch
)

src_configure() {
	local mycmakeargs=()
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install

	dodoc AUTHORS ChangeLog.md docs/{readme_unix,TiTAN.nfo}
	dohtml docs/{FAQ,MilkyTracker}.html

	newicon resources/pictures/carton.png ${PN}.png
	make_desktop_entry ${PN} MilkyTracker ${PN} \
		"AudioVideo;Audio;Sequencer"
}
