# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools eutils gnome2-utils qmake-utils rpm

DESCRIPTION="Easy automated syncing between your computers and your MEGA cloud drive"
HOMEPAGE="http://mega.co.nz"

RELEASE="2.1"

BASE_URL=""

SRC_URI="https://mega.nz/linux/MEGAsync/Fedora_27/src/megasync-${PV}-${RELEASE}.src.rpm"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror"

IUSE="+api chat +curl debug doc dot examples +inotify java libressl +libuv pcre
php python static-libs +sync tests +tools +threads"

REQUIRED_USE="
	sync? ( !java !php !python )
	dot?  ( doc )
"

RDEPEND="
	dev-db/sqlite:3
	dev-libs/crypto++
	dev-libs/libsodium
	dev-qt/qtsvg:5
	dev-qt/qtwidgets:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtdbus:5
	dev-qt/qtcore:5
	media-libs/freeimage
	media-libs/libpng:0
	net-dns/c-ares
	x11-themes/hicolor-icon-theme
	sys-libs/readline:0
	curl? ( net-misc/curl )
	libressl? ( dev-libs/libressl )
	!libressl? ( dev-libs/openssl:0 )
	libuv? ( dev-libs/libuv )
	pcre? ( dev-libs/libpcre )
	php? ( dev-lang/php:* )
	tests? ( dev-cpp/gtest )
"

DEPEND="
	${RDEPEND}
	sys-devel/binutils
	doc? ( app-doc/doxygen[dot=] )
"

PATCHES=(
	"${FILESDIR}"/${P}-enable_install_target.patch
	"${FILESDIR}"/${P}-adapt_distro_version.patch
)

DOCS=(
	MEGASync/mega/CREDITS.md
	MEGASync/mega/LICENSE
	MEGASync/mega/README.md
)

src_prepare() {
	default

	# We then have to prepare the SDK
	pushd "MEGASync/mega" > /dev/null || die
	eautoreconf
	popd > /dev/null || die

	# Now build the translations
	$(qt5_get_bindir)/lrelease MEGASync/MEGASync.pro || die "lrelease failed"
}

src_configure() {
	# We have to prepare the SDK first
	pushd "MEGASync/mega" > /dev/null || die
	econf \
		$(use_enable static-libs)      \
		$(use_enable debug)            \
		$(use_enable inotify)          \
		$(usex !threads --disable-posix-threads "") \
		$(use_enable sync)             \
		$(usex !api --disable-megaapi "") \
		$(use_enable java)             \
		$(use_enable chat)             \
		$(use_enable curl curl-checks) \
		$(use_enable examples)         \
		$(use_enable tools megacmd)    \
		$(use_enable tests)            \
		$(use_enable python)           \
		$(use_enable php)              \
		$(use_enable doc doxygen-doc)  \
		$(use_enable dot doxygen-dot)  \
		--disable-doxygen-ps           \
		$(use_with   java java-include-dir "$(java-config -g JAVA_HOME)/include") \
		$(use_with   libuv libuv "${EPREFIX}/usr/$(get_libdir)") \
		$(use_with   pcre pcre "${EPREFIX}/usr/$(get_libdir)") \
		$(use_with   python python3)

	popd > /dev/null || die

	# Now the global configuration can take place
	eqmake5 \
		CONFIG+=$(usex debug debug release)        \
		$(usex tools    CONFIG+=with_tools    "")  \
		$(usex pcre     QMAKE_LFLAGS+="$(pkg-config --libs libpcre)" "") \
		DEFINES+=no_desktop \
		-recursive MEGA.pro
}

src_compile() {
	# We have to build the SDK first
	pushd "MEGASync/mega" > /dev/null || die
	emake
	popd > /dev/null || die

	default
}

src_install() {
	# We have to install the SDK first
	pushd "MEGASync/mega" > /dev/null || die
	emake DESTDIR="${D}" install
	popd > /dev/null || die

	emake INSTALL_ROOT="${D}" install

	# Install desktop file
	insinto /usr/share/applications
	doins "${S}"/MEGASync/platform/linux/data/megasync.desktop

	# Install icons
	local s SIZES=(16 32 48 128 256)
	local p="${S}"/MEGASync/platform/linux/data/icons/hicolor
	for s in "${SIZES[@]}"; do
		doicon -s $s ${p}/${s}x${s}/apps/mega.png
	done
	local v STATUS=(synching warning paused logging uptodate)
	p="${S}"/MEGASync/gui/images
	for v in "${STATUS[@]}"; do
		newicon -s scalable -c status ${p}/${v}.svg mega${v}.svg
	done

	einstalldocs
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
