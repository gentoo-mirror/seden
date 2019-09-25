# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic meson

DESCRIPTION="The PrydeWorX library of C++ workers, tools and utilities"
HOMEPAGE="https://pwxlib.prydeworx.com"
SRC_URI="https://github.com/Yamakuzure/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="debug doc +spinlocks test +yielding"

REQUIRED_USE="
	yielding? ( spinlocks )
"
DEPEND="${COMMON_DEPEND}
	doc? ( app-doc/doxygen )
	>=sys-devel/gcc-7.4.0
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PV}-fix_docdir.patch
	"${FILESDIR}"/${PV}-fix_find_source_sh.patch
)

src_configure() {
	# Duplicating C[XX]FLAGS in LDFLAGS is deprecated and will become
	# a hard error in future meson versions:
	filter-ldflags $CFLAGS $CXXFLAGS

	local emesonargs=(
		-Ddatadir="${EPREFIX}/usr/share"
		--buildtype $(usex debug debug release)
		--libdir="${EPREFIX}"/usr/$(get_libdir)
		-Dhtml=$(usex doc true false)
		-Dinstall-tests=false
		-Dprofile=false
		-Dsmall_tests=true
		-Dspinlocks=$(usex spinlocks true false)
		-Dtests=$(usex test true false)
		-Dtorture=false
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
