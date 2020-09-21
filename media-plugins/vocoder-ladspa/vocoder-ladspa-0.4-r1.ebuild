# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

RESTRICT=mirror
DESCRIPTION="A vocoder is a sound effect that can make a human voice sound
synthetic"
HOMEPAGE="http://www.sirlab.de/linux/descr_vocoder.html"
SRC_URI="http://www.sirlab.de/linux/download/${P}.tgz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86"
IUSE=""

DEPEND="media-libs/ladspa-sdk"
RDEPEND="${DEPEND}"

MY_P="${P/-ladspa/}"
S=${WORKDIR}/${MY_P}

src_unpack(){
	unpack ${A}
	cd "${S}"
}
src_compile() {
	emake || die
}

src_install() {
	dodoc COPYRIGHT README
	insinto /usr/$(get_libdir)/ladspa
	insopts -m0755
	doins vocoder.so
}
