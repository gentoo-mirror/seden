# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools eutils gnome2-utils qmake-utils rpm xdg-utils

DESCRIPTION="Easy automated syncing between your computers and your MEGA cloud drive"
HOMEPAGE="http://mega.co.nz"

RELEASE="1"

BASE_URL=""

SRC_URI="https://mega.nz/linux/MEGAsync/Fedora_29/src/megasync-${PV}-${RELEASE}.src.rpm"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror"

IUSE="+api chat +curl debug doc dot examples +ffmpeg +inotify java +libmediainfo
	libressl +libuv +libraw +libsodium pcre php python +sync tests +tools +threads"

REQUIRED_USE="
	dot?  ( doc )
	libmediainfo? ( threads )
	sync? ( !java !php !python )
"

RDEPEND="
	dev-db/sqlite:3
	dev-libs/crypto++
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
	sys-libs/readline:=
	curl? ( net-misc/curl )
	ffmpeg? ( virtual/ffmpeg )
	libmediainfo? (
		media-libs/libmediainfo
		media-libs/libzen
	)
	libressl? ( dev-libs/libressl:0 )
	!libressl? ( dev-libs/openssl:0 )
	libraw? ( media-libs/libraw:0 )
	libsodium? ( dev-libs/libsodium:0 )
	libuv? ( dev-libs/libuv:0 )
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
	"${FILESDIR}"/${P}-fix_strict_aliasing.patch
)

DOCS=(
	MEGASync/mega/CREDITS.md
	MEGASync/mega/LICENSE
	MEGASync/mega/README.md
)

src_prepare() {
	default

	# Some options, although configurable in the configure script, are hard-
	# coded in the MEGASync.pro file. Stupid thing to do, really...
	if ! use ffmpeg; then
		sed -i \
			-e '/CONFIG.*USE_FFMPEG/ s/^/#/' \
			-e '/DEFINES.*REQUIRE_HAVE_FFMPEG/ s/^/#/' \
			MEGASync/MEGASync.pro || die "FFMPEG disabling failed"
	fi
	if ! use libmediainfo; then
		sed -i \
			-e '/CONFIG.*USE_MEDIAINFO/ s/^/#/' \
			-e '/DEFINES.*REQUIRE_USE_MEDIAINFO/ s/^/#/' \
			MEGASync/MEGASync.pro || die "MEDIAINFO disabling failed"
	fi
	if ! use libraw; then
		sed -i \
			-e '/CONFIG.*USE_LIBRAW/ s/^/#/' \
			-e '/DEFINES.*REQUIRE_HAVE_LIBRAW/ s/^/#/' \
			MEGASync/MEGASync.pro || die "LIBRAW disabling failed"
	fi
	if ! use libuv; then
		sed -i \
			-e '/CONFIG.*USE_LIBUV/ s/^/#/' \
			-e '/DEFINES.*REQUIRE_HAVE_LIBUV/ s/^/#/' \
			MEGASync/MEGASync.pro || die "LIBUV disabling failed"
	fi

	# We then have to prepare the SDK
	pushd "MEGASync/mega" > /dev/null || die
	eautoreconf
	popd > /dev/null || die

	# Now build the translations
	$(qt5_get_bindir)/lrelease MEGASync/MEGASync.pro || die "lrelease failed"
}

src_configure() {
	# First configure the SDK
	pushd "MEGASync/mega" > /dev/null || die
	econf \
		$(use_enable debug)               \
		$(use_enable inotify)             \
		$(usex !threads --disable-posix-threads "") \
		$(use_enable sync)                \
		$(usex !api --disable-megaapi "") \
		$(use_enable java)                \
		$(use_enable chat)                \
		$(use_enable curl curl-checks)    \
		$(use_enable examples)            \
		$(use_enable tests)               \
		$(use_enable python)              \
		$(use_enable php)                 \
		$(use_enable doc doxygen-doc)     \
		$(use_enable dot doxygen-dot)     \
		--disable-doxygen-ps              \
		$(use_with   ffmpeg       ffmpeg           "${EPREFIX}/usr/$(get_libdir)")        \
		$(use_with   java         java-include-dir "$(java-config -g JAVA_HOME)/include") \
		$(use_with   libuv        libuv            "${EPREFIX}/usr/$(get_libdir)")        \
		$(use_with   libmediainfo libmediainfo     "${EPREFIX}/usr/$(get_libdir)")        \
		$(use_with   libmediainfo libzen           "${EPREFIX}/usr/$(get_libdir)")        \
		$(use_with   libraw       libraw           "${EPREFIX}/usr/$(get_libdir)")        \
		$(use_with   libsodium    sodium           "${EPREFIX}/usr/$(get_libdir)")        \
		$(use_with   pcre         pcre             "${EPREFIX}/usr/$(get_libdir)")        \
		$(use_with   python       python3) \
		|| die "SDK configure failed"
	popd > /dev/null || die

	# Now the global configuration can take place
	eqmake5 \
		CONFIG+=$(usex debug debug release)        \
		$(usex tools         CONFIG+=with_tools    "") \
		$(usex pcre          QMAKE_LFLAGS+="$(pkg-config --libs libpcre)" "") \
		$(usex ffmpeg        CONFIG+=USE_FFMPEG    "") \
		$(usex libmediainfo  CONFIG+=USE_MEDIAINFO "") \
		$(usex libraw        CONFIG+=USE_LIBRAW    "") \
		$(usex libuv         CONFIG+=USE_LIBUV     "") \
		DEFINES+=no_desktop \
		-recursive MEGA.pro || die "qmake failed"
}

src_compile() {
	# We have to build the SDK first
	pushd "MEGASync/mega" > /dev/null || die
	emake
	popd > /dev/null || die

	default
}

pkg_preinst() {
	gnome2_icon_savelist
}

src_install() {
	# We have to install the SDK first
	pushd "MEGASync/mega" > /dev/null || die
	emake DESTDIR="${D}" install
	popd > /dev/null || die

	emake INSTALL_ROOT="${D}" install

	# The tools must be installed manually, as the build system isn't meant
	# to do that automatically.
	if use tools; then
		dobin MEGASync/mega/contrib/QtCreator/MEGACli/MEGAcli
		dobin MEGASync/mega/contrib/QtCreator/MEGASimplesync/MEGAsimplesync
	fi

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

	# Remove unwanted .la files
	find "${ED}"/ -name '*.la' -delete || die

	# The build system adds some unneeded files (distro, version)
	# in an unwanted directory.
	rm -rf "${ED}"/usr/share/doc/${PN}
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
	xdg_mimeinfo_database_update
}
