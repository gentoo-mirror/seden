# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit eutils toolchain-funcs

DESCRIPTION="RTF to LaTeX converter"
HOMEPAGE="http://rtf2latex2e.sourceforge.net"
SRC_URI="mirror://sourceforge/project/${PN}/${PN}-unix/2-2/${PN}-2-2-3.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~hppa ~sparc ~x86"
IUSE="doc test unoconv"
SLOT="0"
S="${WORKDIR}/${PN}-2-2-3"

RDEPEND="virtual/latex-base
	unoconv? ( app-office/unoconv )
"
DEPEND="${RDEPEND}
	doc? (
		dev-tex/hevea
		virtual/latex-base
		virtual/man
	)
"
PATCHES=(
)

src_prepare() {
	# Stupid release...
	mv "${S}"/doc/Changelog "${S}"/doc/ChangeLog
	default
}
src_compile() {
	# Set DESTDIR here too so that compiled-in paths are correct.
	emake CC="$(tc-getCC)" LD="$(tc-getLD)" AR="$(tc-getAR)" \
		prefix="${EPREFIX}/usr" DESTDIR="${EPREFIX}/usr" CC="$(tc-getCC)" || \
		die "emake failed"

	if use doc; then
		cd "${S}/doc"
		emake CC="$(tc-getCC)" realclean
		# Those are missing:
		touch header.html footer.html
		emake CC="$(tc-getCC)" LD="$(tc-getLD)" AR="$(tc-getAR)" || die "emake doc failed"
	fi

	if use test; then
		cd "${S}/test"
		emake CC="$(tc-getCC)" realclean
		emake CC="$(tc-getCC)" LD="$(tc-getLD)" AR="$(tc-getAR)" || die "emake test failed"
		cd "${S}"
	fi
}

src_test() {
	cd "${S}/test"
	emake CC="$(tc-getCC)" realclean
	emake CC="$(tc-getCC)" LD="$(tc-getLD)" AR="$(tc-getAR)" || die "emake test failed"
	cd "${S}"
}

src_install() {
	dodoc README doc/ChangeLog doc/GPL_license
	emake CC="$(tc-getCC)" LD="$(tc-getLD)" AR="$(tc-getAR)" prefix="${EPREFIX}/usr" DESTDIR="${ED}" install
	if use doc; then
		dodoc doc/web/{arrow.gif,docs.html,index.html,logo.png,MTEF3.html}
		dodoc doc/web/{MTEF4.html,MTEF5.html,quadratic2.png,style.css}
		dodoc doc/rtf2latexDoc.pdf
	fi
}
