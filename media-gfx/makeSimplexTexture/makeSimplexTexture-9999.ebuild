# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils git-r3 toolchain-funcs

DESCRIPTION="Build textures with bumpmaps using simplex noise."
HOMEPAGE="https://prydeworx.com/makeSimplexTexture"
EGIT_REPO_URI="https://github.com/Yamakuzure/makeSimplexTexture.git"
EGIT_BRANCH="master"
EGIT_SUBMODULES=()

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="debug"

COMMON_DEPEND="
	>=dev-cpp/pwxlib-0.9.0
	>=media-libs/libsfml-2.5.1
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

DOCS=()

src_compile() {
	PREFIX="${EPREFIX}"/usr CXXFLAGS="${CXXFLAGS}" \
		CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
		CXX="$(tc-getCXX)" LD="$(tc-getCC)" \
		DEBUG="$(usex debug YES NO)" \
		emake || die "emake failed"
}

src_install() {
	PREFIX="${EPREFIX}"/usr DESTDIR="${D}" \
		DOCDIR="${EPREFIX}"usr/share/doc/${PF} \
		emake install || die "install failed"
}
