# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils gnome2-utils games versionator

MY_PV=$(get_version_component_range 1-2)-aiu$(get_version_component_range 3)
MY_PN=atanks
MY_P=${MY_PN}-${MY_PV}

DESCRIPTION="Worms and Scorched Earth-like game (AI Upgrade project)"
HOMEPAGE="http://atanksaiupgrade.sourceforge.net/"
SRC_URI="mirror://sourceforge/atanksaiupgrade/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="debug"

DEPEND="
    media-libs/allegro:0[X]
    !games-action/atanks"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	find . -type f -name ".directory" -exec rm -vf '{}' +
}

src_compile() {
	xDebug="NO"
	if use debug; then
	    xDebug="YES"
	fi
	
	emake \
		BINDIR="${GAMES_BINDIR}" \
		INSTALLDIR="${GAMES_DATADIR}/${MY_PN}" \
		DEBUG=$xDebug
}

src_install() {
	dogamesbin ${MY_PN}
	insinto "${GAMES_DATADIR}"/${MY_PN}
	doins -r button misc missile sound stock tank tankgun text title unicode.dat *.txt
	doicon -s 48 ${MY_PN}.png
	make_desktop_entry atanks "Atomic Tanks (AI Upgrade)"
	dodoc Changelog README TODO
	prepgamesdirs
}

pkg_preinst() {
	games_pkg_preinst
	gnome2_icon_savelist
}

pkg_postinst() {
	games_pkg_postinst
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
