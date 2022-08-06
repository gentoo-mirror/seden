# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic git-r3

KERNELS_DIR="opt/lib"

DESCRIPTION="Ethereum miner with CUDA and stratum support"
HOMEPAGE="https://github.com/ethereum-mining/ethminer"

EGIT_REPO_URI="https://github.com/ethereum-mining/${PN}.git"
EGIT_SUBMODULES=( cmake/cable )

KEYWORDS=""

LICENSE="GPL-3+ LGPL-3+"
SLOT="0"
IUSE="apicore binkern cpu cuda dbus debug +opencl verbose-debug +system-opencl"

QA_PREBUILT="${KERNELS_DIR}/ethash_*"

RDEPEND="
	dev-cpp/ethash
	>=dev-cpp/libjson-rpc-cpp-1.0.0[http-client]
	dev-libs/boost
	dev-libs/jsoncpp
	dev-libs/openssl
	cuda? ( dev-util/nvidia-cuda-toolkit )
	dbus? ( sys-apps/dbus )
	opencl? ( virtual/opencl )
"
DEPEND="${RDEPEND}
	dbus? ( virtual/pkgconfig )
	acct-user/ethminer
"
BDEPEND="
	>=dev-util/cmake-3.5
	dev-cpp/cli11
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PV}-fix_compilation_issues.patch
)

src_unpack() {
	default

	if [[ ${PV} == 9999 ]]
	then
		git-r3_src_unpack
		return
	fi

	rmdir "${S}"/cmake/cable || die
	mv cable-${CABLE_VER} "${S}"/cmake/cable || die
}

src_prepare() {
	rm cmake/cable/HunterGate.cmake || die

	find -name CMakeLists.txt | xargs sed -i \
		-e '/find_package/ s/CONFIG//' \
		-e '/hunter_add_package/d'

	find -name *.h | xargs sed -i \
		-e '/include.*json/ s:json/json\.h:jsoncpp/&:'

	sed -i \
		-e '/include.*Hunter/d' \
		-e '/^HunterGate(/,/^)/d' \
		-e '/cable_set_build_type/d' \
		-e '/find_package.*jsoncpp/d' \
		CMakeLists.txt || die

	sed -i \
		-e '/include_directories.+BEFORE/ s:\.\.:& \.:' \
		-e '/find_package.*CLI11/d' \
		-e '/target_link_libraries/ s/CLI11::CLI11//' \
		-e 's/target_link_libraries.*ethminer.*PRIVATE/& crypto/' \
		-e '/find_package.*PkgConfig/ s/PkgConfig/DBus1 REQUIRED/' \
		-e '/set.*ENV/d' \
		-e '/pkg_check_modules.*DBUS/d' \
		-e '/include_directories.*DBUS_INCLUDE_DIRS/ s/DBUS/DBus1/' \
		-e '/link_directories.*DBUS/d' \
		-e '/target_link_libraries.*DBUS_LIBRARIES/ s/DBUS_LIBRARIES/DBus1_LIBRARY/' \
		ethminer/CMakeLists.txt || die

	sed -i \
		-e '/target_link_libraries/ s/ethcore//' \
		libethash-{cl,cpu,cuda}/CMakeLists.txt

	sed -i \
		-e "/install/ s:\(DESTINATION.*\)\$.*kernels:\1/${KERNELS_DIR}:" \
		libethash-cl/kernels/CMakeLists.txt

	sed -i \
		-e 's/jsoncpp_lib_static/jsoncpp/' \
		-e 's/jsoncpp_static/jsoncpp/' \
		libpoolprotocols/CMakeLists.txt || die

	sed -i \
		-e 's/fname_strm.*<<.*program_location.*/fname_strm/' \
		-e "s:/kernels/ethash_:/${KERNELS_DIR}/ethash_:" \
		libethash-cl/CLMiner.cpp

	sed -i \
		-e 's/get_io_service()/context()/' \
		libethcore/Farm.cpp || die

	sed -i \
		-e '/boost::bind/ s/_1/boost::placeholders::_1/' \
		libpoolprotocols/getwork/EthGetworkClient.cpp || die

	if [[ ${PV} != 9999 ]]
	then
		sed -i -e '/find_package.*Git/d' \
			cmake/cable/CableBuildInfo.cmake
	fi

	# fix build with >nvidia-cuda-toolkit-10.2 (https://stackoverflow.com/q/64774548/5424487)
	sed -i -e 's/compute_30/compute_50/' -e 's/sm_30/sm_50/' libethash-cuda/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycxxflags=(
		-Wno-deprecated-declarations
		-I"${WORKDIR}/CLI11-${CLI11_VER}/include"
		-DBOOST_BIND_GLOBAL_PLACEHOLDERS
	)

	append-cxxflags ${mycxxflags[@]}

	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF

		-DAPICORE=$(usex apicore)
		-DBINKERN=$(usex binkern)
		-DDEVBUILD=$(usex verbose-debug)
		-DETHASHCL=$(usex opencl)
		-DETHASHCPU=$(usex cpu)
		-DETHASHCUDA=$(usex cuda)
		-DETHDBUS=$(usex dbus)
		-DUSE_SYS_OPENCL=$(usex system-opencl)
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

##	newinitd "${FILESDIR}/${PN}-initd" "${PN}"
##	newconfd "${FILESDIR}/${PN}-confd" "${PN}"

	keepdir /var/{lib,log}/ethminer
	fowners ethminer:ethminer /var/{lib,log}/ethminer
}
