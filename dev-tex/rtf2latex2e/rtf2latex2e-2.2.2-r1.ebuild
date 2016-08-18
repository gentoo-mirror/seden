# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

inherit eutils

DESCRIPTION="RTF to LaTeX converter"
HOMEPAGE="http://rtf2latex2e.sourceforge.net"
SRC_URI="mirror://sourceforge/project/${PN}/${PN}-unix/2-2/${PN}-2-2-2.tar.gz"

# http://sourceforge.net/projects/rtf2latex2e/files/rtf2latex2e-unix/2-2/rtf2latex2e-2-2-2.tar.gz/download
# http://downloads.sourceforge.net/project/rtf2latex2e/rtf2latex2e-unix/2-2/rtf2latex2e-2-2-2.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Frtf2latex2e%2Ffiles%2Frtf2latex2e-unix%2F2-2%2F&ts=1371471286&use_mirror=kent

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
SLOT="0"
IUSE="doc test unoconv"
S="${WORKDIR}/${PN}-2-2-2"

RDEPEND="virtual/latex-base
	unoconv? ( app-office/unoconv )"
DEPEND="${RDEPEND}
	doc? (
		dev-tex/hevea
		virtual/latex-base
		virtual/man
	)"

src_prepare() {
	epatch "${FILESDIR}"/fix_man2html_call.patch
	epatch "${FILESDIR}"/fix_hevea_call.patch
	eapply_user
}

src_compile() {
	# Set DESTDIR here too so that compiled-in paths are correct.
	emake prefix="${EPREFIX}/usr" DESTDIR="${EPREFIX}/usr" CC="$(tc-getCC)" || \
		die "emake failed"

	if use doc; then
		cd "${S}/doc"
		emake realclean
		# Those are missing:
		touch header.html footer.html
		emake -j1 || die "emake doc failed"
	fi

	if use test; then
		cd "${S}/test"
		emake realclean
		emake -j1 || die "emake test failed"
		cd "${S}"
	fi
}

src_test() {
	cd "${S}/test"
	emake realclean
	emake -j1 || die "emake test failed"
	cd "${S}"
}

src_install() {
	dodoc README doc/ChangeLog doc/GPL_license
	emake prefix="${EPREFIX}/usr" DESTDIR="${ED}" -j1 install
	if use doc; then
		dodoc doc/web/manpage.html doc/web/usage.html doc/rtf2latexDoc.pdf
	fi
}
