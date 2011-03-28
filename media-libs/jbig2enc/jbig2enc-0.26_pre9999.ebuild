# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit git

DESCRIPTION="jbig2enc is an encoder for JBIG2"
HOMEPAGE="https://github.com/agl/jbig2enc"
EGIT_REPO_URI="https://github.com/agl/jbig2enc.git"
SRC_URI=""

LICENSE="Leptonica"
KEYWORDS="~x86 ~amd64"
IUSE=""

SLOT="0"

RDEPEND="
	~media-libs/leptonica-0.67
	virtual/jpeg
	media-libs/libpng
	media-libs/tiff
"
DEPEND="${DEPEND} ${RDEPEND}"

src_prepare() {
	# The makefile is written for local usage and has to be
	# adapted to system usage (or rewritten...) :
	epatch "${FILESDIR}/local_to_gentoo_makefile.diff" \
		|| die "epatch failed"
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	dobin jbig2
	dolib.a libjbig2enc.a
	dodoc LEPTONICA_VERSION PATENTS README
	insinto /usr/include/jbig2enc
	doins jbig2arith.h jbig2enc.h jbig2segments.h jbig2structs.h jbig2sym.h
}
