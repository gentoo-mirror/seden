# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic git-r3 meson

DESCRIPTION="The PrydeWorX library of C++ workers, tools and utilities"
HOMEPAGE="https://pwxlib.prydeworx.com"
EGIT_REPO_URI="https://github.com/Yamakuzure/pwxlib.git"
EGIT_BRANCH="master"
EGIT_SUBMODULES=()

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="annotations asan debug debug-thread doc lsan profile +spinlocks test
torture tsan +yielding"

REQUIRED_USE="
	?? ( annotations debug-thread )
	?? ( asan lsan tsan )
	annotations? ( !spinlocks !yielding )
	asan? ( debug )
	lsan? ( debug )
	profile? ( !debug !debug-thread )
	tsan? ( debug )
	yielding? ( spinlocks )
"
COMMON_DEPEND="
	debug-thread? ( dev-util/valgrind )
"
DEPEND="${COMMON_DEPEND}
	doc? ( app-doc/doxygen )
	>=sys-devel/gcc-8.2.0
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}"

src_configure() {
	local b_san

	# Duplicating C[XX]FLAGS in LDFLAGS is deprecated and will become
	# a hard error in future meson versions:
	filter-ldflags $CFLAGS $CXXFLAGS

	# See what kind of sanitization is wanted
	if use asan; then
		export ASAN_OPTIONS=detect_leaks=0
		b_san="-Db_sanitize=address"
	elif use lsan; then
		export ASAN_OPTIONS=detect_leaks=1
		b_san="-Db_sanitize=address"
	elif use tsan; then
		b_san="-Db_sanitize=thread"
	fi

	local emesonargs=(
		-Ddocdir="${EPREFIX}/usr/share/doc/${PF}"
		--buildtype $(usex debug debug release)
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		-Dannotations=$(usex annotations true false)
		-Ddebug-extra=$(usex debug true false)
		-Ddebug-thread=$(usex debug-thread true false)
		-Dhtml=$(usex doc true false)
		-Dinstall-tests=$(usex test true false)
		-Dprofile=$(usex profile true false)
		-Dspinlocks=$(usex spinlocks true false)
		-Dtests=$(usex test true false)
		-Dtorture=$(usex torture true false)
		-Dyielding=$(usex yielding true false)
		$b_san
	)

	meson_src_configure
}

src_install() {
	DOCS=(
		AUTHORS
		ChangeLog
		code_of_conduct.md
		CONTRIBUTING.md
		INSTALL.md
		LICENSE
		NEWS.md
		README.md
		TODO.md
	)

	meson_src_install
}

pkg_postinst() {
	if use debug-thread; then
		ewarn "You have enabled USE=\"debug-thread\""
		ewarn "This flag enables an excessive amount of debug"
		ewarn "messages, which are only useful if you work on"
		ewarn "the multi-threading code of pwxlib itself."
	fi
}
