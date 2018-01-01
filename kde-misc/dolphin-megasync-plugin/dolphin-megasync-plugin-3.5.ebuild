# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit cmake-utils eutils gnome2-utils rpm

DESCRIPTION="Extension for Dolphin to interact with Megasync"
HOMEPAGE="http://mega.co.nz"

RELEASE="2.1"

SRC_URI="https://mega.nz/linux/MEGAsync/Fedora_27/src/dolphin-megasync-${PV}-${RELEASE}.src.rpm"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror"

IUSE=""

RDEPEND="
	kde-apps/dolphin
	kde-frameworks/kio
	kde-frameworks/kdelibs4support
	net-misc/megasync[api]
"

DEPEND="
	${RDEPEND}
	sys-devel/binutils
	dev-util/cmake
"

PATCHES=(
	"${FILESDIR}"/${P}-fix_KPluginFactory_invocation.patch
)

S="${WORKDIR}/dolphin-megasync-${PV}"

src_unpack() {
	rpm_src_unpack

	# Unfortunately the CMakeLists.txt file is for KDE4.
	cd "${S}"
	mv CMakeLists.txt CMakeLists_kde4.txt
	mv CMakeLists_kde5.txt CMakeLists.txt
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
