# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="A file archiver with a high compression ratio"
HOMEPAGE="https://7-zip.org"
SRC_URI="mirror://sourceforge/project/sevenzip/7-Zip/${PV}/7z$(ver_rs 1 '')-src.tar.xz"
RESTRICT="mirror"
S="${WORKDIR}"

LICENSE="LGPL-2.1 BSD rar? ( unRAR )"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+asm rar static"

RDEPEND="!app-arch/p7zip"
DEPEND="${RDEPEND}"
BDEPEND="
	asm? ( dev-lang/jwasm )
"

DOCS=(
	DOC/7zC.txt
	DOC/7zFormat.txt
	DOC/lzma.txt
	DOC/Methods.txt
	DOC/readme.txt
	DOC/src-history.txt
)

PATCHES=(
	"${FILESDIR}/7-zip-flags.patch"
)

src_prepare() {
	# Fix line endings so 7-zip-flags.patch
	sed -i \
		-e 's/\r$//' \
		CPP/7zip/7zip_gcc.mak C/7zip_gcc_c.mak \
		|| die 'sed failed'
	default
}

src_compile() {
	local myemakeargs=(
		CFLAGS_BASE2="${CFLAGS}"
		CXXFLAGS_BASE2="${CXXFLAGS}"
		CFLAGS_WARN_WALL='-Wall -Wextra'
		IS_X64=1
		USE_ASM=$(usex asm 1 '')
		USE_JWASM=$(usex asm 1 '')
		COMPL_STATIC=$(usex static 1 '')
		O="${S}"
		DISABLE_RAR=$(usex rar '' 1)
	)
	tc-env_build emake \
		-C CPP/7zip/Bundles/Alone2 \
		-f makefile.gcc \
		"${myemakeargs[@]}"
}

src_install() {
	dobin 7zz$(usex static 's' '')
	dosym 7zz /usr/bin/7z
	einstalldocs
}
