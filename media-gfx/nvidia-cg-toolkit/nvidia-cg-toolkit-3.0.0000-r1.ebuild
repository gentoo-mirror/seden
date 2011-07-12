# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit versionator

MY_PV="$(get_version_component_range 1-2)"
MY_DATE="July2010"
DESCRIPTION="NVIDIA's C graphics compiler toolkit"
HOMEPAGE="http://developer.nvidia.com/object/cg_toolkit.html"
SRC_URI="x86? ( http://developer.download.nvidia.com/cg/Cg_${MY_PV}/Cg-${MY_PV}_${MY_DATE}_x86.tgz )
	amd64? ( http://developer.download.nvidia.com/cg/Cg_${MY_PV}/Cg-${MY_PV}_${MY_DATE}_x86_64.tgz )"

LICENSE="NVIDIA"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="strip"

SLOT="0"

RDEPEND="media-libs/freeglut"

S=${WORKDIR}

DEST=/opt/${PN}

src_install() {
	into ${DEST}
	dobin usr/bin/cgc || die
	dosym ${DEST}/bin/cgc /usr/bin/cgc || die

	exeinto ${DEST}/lib
	if use x86 ; then
		doexe usr/lib/* || die
	elif use amd64 ; then
		doexe usr/lib64/* || die
	fi

	doenvd "${FILESDIR}"/80cgc-opt

	insinto ${DEST}/include/Cg
	doins usr/include/Cg/*
	dosym ${DEST}/include/Cg /usr/include/Cg

	insinto ${DEST}/man/man3
	doins usr/share/man/man3/*

	insinto ${DEST}
	doins -r usr/local/Cg/{docs,examples,README}
}
