# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
KDE_REQUIRED="optional"
inherit kde4-base kde5-functions git-r3

DESCRIPTION="A set of widget styles for Qt and GTK2"
HOMEPAGE="https://quickgit.kde.org/?p=qtcurve.git"
EGIT_REPO_URI="git://anongit.kde.org/qtcurve"

LICENSE="LGPL-2+"
SLOT="0"
IUSE="+X gtk2 kde nls plasma +qt4 qt5 test windeco"
KEYWORDS=""

REQUIRED_USE="gtk2? ( X )
	windeco? ( X
		|| ( kde plasma )
	)
	|| ( gtk2 qt4 qt5 )
	kde? ( qt4 windeco )
	plasma? ( qt5 windeco )
"

RDEPEND="X? ( x11-libs/libxcb
		x11-libs/libX11 )
	gtk2? ( x11-libs/gtk+:2 )
	qt4? ( dev-qt/qtdbus:4
		dev-qt/qtgui:4
		dev-qt/qtsvg:4
	)
	qt5? ( dev-qt/qtdeclarative:5
		dev-qt/qtgui:5
		dev-qt/qtsvg:5
		dev-qt/qtwidgets:5
		X? ( dev-qt/qtdbus:5
			dev-qt/qtx11extras:5 )
	)
	kde? ( $(add_kdebase_dep systemsettings)
		windeco? ( $(add_kdebase_dep kwin) )
	)
	plasma? ( $(add_plasma_dep systemsettings)
		windeco? ( $(add_plasma_dep kwin) )
	)
	!x11-themes/gtk-engines-qtcurve"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

S="${WORKDIR}/${P/_/}"

DOCS=( AUTHORS ChangeLog.md README.md TODO.md )

PATCHES=(
		"${FILESDIR}/${P}-gtk2_segfault.patch"
		"${FILESDIR}/${P}-add_uitls_include.patch"
	)

pkg_setup() {
	# bug #498776
	if ! version_is_at_least 4.7 $(gcc-version) ; then
		append-cxxflags -Doverride=
	fi

#	use kde && kde4-base_pkg_setup
}

src_configure() {
	local mycmakeargs

	mycmakeargs=(
		-DENABLE_GTK2="$(usex gtk2)"
		-DENABLE_QT4="$(usex qt4)"
		-DENABLE_QT5="$(usex qt5)"
		-DENABLE_TEST="$(usex test)"
		-DQTC_ENABLE_X11="$(usex X)"
		-DQTC_INSTALL_PO="$(usex nls)"
		-DQTC_QT4_ENABLE_KDE="$(usex kde)"
		-DQTC_QT4_STYLE_SUPPORT="(usex qt4)"
		-DQTC_QT5_ENABLE_KDE="$(usex plasma)"
	)


	cmake-utils_src_configure
}
