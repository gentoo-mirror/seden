# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg rpm

DESCRIPTION="Cisco video conferencing and online meeting software"
HOMEPAGE="https://www.webex.com/"
SRC_URI="https://binaries.webex.com/WebexDesktop-CentOS-Official-Package/Webex.rpm -> ${P}.rpm"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="-* ~amd64"
IUSE=""

RESTRICT="bindist mirror strip"

DEPEND=""
RDEPEND="
	>=app-accessibility/at-spi2-core-2.46.0
	app-crypt/libsecret
	app-crypt/tpm2-tss[mbedtls]
	dev-libs/nss
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/libglvnd
	media-libs/libpulse
	media-libs/mesa
	sys-apps/lshw
	sys-power/upower
	virtual/libcrypt
	virtual/libudev
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXrandr
	x11-libs/libnotify
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
"

S=${WORKDIR}

QA_PREBUILT="*"

src_install() {
	mv opt "${D}/" || die

	# dodir /usr/lib/debug
	# mv usr/lib/.build-id "${D}/usr/lib/debug/" || die

	sed -e 's:Utility;Application;:Network;InstantMessaging;:g' -i "${D}/opt/Webex/bin/webex.desktop"
	sed -e '/^Version=.*$/d' -i "${D}/opt/Webex/bin/webex.desktop"

	domenu "${D}/opt/Webex/bin/webex.desktop"
	doicon "${D}/opt/Webex/bin/sparklogosmall.png"
}
