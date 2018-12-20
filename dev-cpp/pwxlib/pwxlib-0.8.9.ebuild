# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic meson

DESCRIPTION="The PrydeWorX library of C++ workers, tools and utilities"
HOMEPAGE="https://pwxlib.prydeworx.com"
SRC_URI="https://github.com/Yamakuzure/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="annotations debug debug-thread doc graphite profile +spinlocks test torture +yielding"

REQUIRED_USE="
	?? ( annotations debug-thread )
	profile? ( !debug !debug-thread )
	yielding? ( spinlocks )
"
COMMON_DEPEND="
	debug-thread? ( dev-util/valgrind )
"
DEPEND="${COMMON_DEPEND}
	doc? ( app-doc/doxygen )
	>=sys-devel/gcc-8.2.0[graphite?]
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}"

src_configure() {
	# Duplicating C[XX]FLAGS in LDFLAGS is deprecated and will become
	# a hard error in future meson versions:
	filter-ldflags $CFLAGS $CXXFLAGS

	local emesonargs=(
		-Ddocdir="${EPREFIX}/usr/share/doc/${PF}"
		--buildtype $(usex debug debug release)
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		-Dannotations=$(usex annotations true false)
		-Ddebug-extra=$(usex debug true false)
		-Ddebug-thread=$(usex debug-thread true false)
		-Dgraphite=$(usex graphite true false)
		-Dhtml=$(usex doc true false)
		-Dinstall-tests=$(usex test true false)
		-Dprofile=$(usex profile true false)
		-Dspinlocks=$(usex spinlocks true false)
		-Dtests=$(usex test true false)
		-Dtorture=$(usex torture true false)
		-Dyielding=$(usex yielding true false)
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
