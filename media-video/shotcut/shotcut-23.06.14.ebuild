# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic xdg

DESCRIPTION="A free, open source, cross-platform video editor"
HOMEPAGE="https://www.shotcut.org/ https://github.com/mltframework/shotcut/"
if [[ ${PV} != 9999* ]] ; then
	SRC_URI="https://github.com/mltframework/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/mltframework/shotcut/"
fi
KEYWORDS="~amd64"

IUSE="debug"

LICENSE="GPL-3+"
SLOT="0"

BDEPEND="
	dev-qt/qttools:6[linguist]
"
DEPEND="
	dev-qt/qtbase:6[concurrent,dbus,gui,network,opengl,sql,vulkan,widgets,xml]
	dev-qt/qtdeclarative:6[widgets]
	dev-qt/qtmultimedia:6
	dev-qt/qtwebsockets:6
	>=media-libs/mlt-7.16.0-r100[ffmpeg,frei0r,fftw(+),jack,opengl,qt6,sdl,xml]
	x11-libs/libxkbcommon
	media-video/ffmpeg
"
RDEPEND="${DEPEND}
	virtual/jack
"

src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug Debug Release)
	local mycmakeargs=(
		-DSHOTCUT_VERSION="${PV}"
	)
	use debug || append-cxxflags "-DNDEBUG"
	append-cxxflags "-DSHOTCUT_NOUPGRADE"
	cmake_src_configure
}
