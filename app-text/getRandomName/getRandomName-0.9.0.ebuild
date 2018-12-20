# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Create random names using linguistic rules"
HOMEPAGE="https://prydeworx.com/getRandomNames"
SRC_URI="https://github.com/Yamakuzure/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

COMMON_DEPEND="
	dev-cpp/pwxlib
"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

DOCS=()

src_prepare() {
	# Makefile is a symlink to Makefile.Linux, avoid that we patch it by
	# accident using patch <2.7, see bug #435492
	rm Makefile || die

	EPATCH_SUFFIX="patch" epatch "${WORKDIR}/${PN}-gentoo-patches-${PATCHVER}"

	# Re-add convenience symlink, see above
	ln -s Makefile.Linux Makefile

	epatch "${FILESDIR}"/${P}-CVE-2014-8123.patch
}

src_configure() { :; }

src_compile() {
	emake PREFIX="${EPREFIX}/usr" CPPFLAGS="${CPPFLAGS}" CXXFLAGS="${CXXFLAGS}" \
		CXX="$(tc-getCXX)" LD="$(tc-getCC)" LDFLAGS="${LDFLAGS}" \
		|| die "emake failed"
}

src_install() {
	emake PREFIX="${EPREFIX}" DESTDIR="${D}" \
		DOCDIR="${EPREFIX}"/usr/share/doc/${PF} install \
		|| die "install failed"
}
