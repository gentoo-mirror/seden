# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils git-r3 toolchain-funcs

DESCRIPTION="Create random names using linguistic rules"
HOMEPAGE="https://prydeworx.com/getRandomNames"
EGIT_REPO_URI="https://github.com/Yamakuzure/getRandomName.git"
EGIT_BRANCH="master"
EGIT_SUBMODULES=()

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="asan debug lsan tsan"

REQUIRED_USE="
	?? ( asan lsan tsan )
	asan? ( debug )
	lsan? ( debug )
	tsan? ( debug )
"

COMMON_DEPEND="
	dev-cpp/pwxlib
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

DOCS=()

src_compile() {
	PREFIX="${EPREFIX}"usr CXXFLAGS="${CXXFLAGS}" \
		CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
		CXX="$(tc-getCXX)" LD="$(tc-getCC)" \
		DEBUG="$(usex debug YES NO)" \
		SANITIZE_ADDRESS="$(usex asan YES NO)" \
		SANITIZE_LEAK="$(usex lsan YES NO)" \
		SANITIZE_THREAD="$(usex tsan YES NO)" \
		emake || die "emake failed"
}

src_install() {
	PREFIX="${EPREFIX}"usr DESTDIR="${D}" \
		DOCDIR="${EPREFIX}"usr/share/doc/${PF} \
		emake install || die "install failed"
}