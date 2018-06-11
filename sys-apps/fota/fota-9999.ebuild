# Copyright (c) 2018 Samsung Electronics Co., Ltd All Rights Reserved
# Distributed under the terms of the GNU General Public License v2

EAPI=6

REPO_PATH="git.tizen.org/tools/muxpi"
EGO_PN="${REPO_PATH}/sw/nanopi"
S=${WORKDIR}/${P}/src/${REPO_PATH}

EGO_VENDOR=(
"golang.org/x/sys bff228c7b664c5fce602223a05fb708fd8654986 github.com/golang/sys"
"periph.io/x/periph c0de80b1b075a2019fced09524f2318cf690a685 github.com/google/periph"
"gopkg.in/fsnotify/fsnotify.v1 c2828203cd70a50dcccfb2761f8b1f8ceef9a8e9 github.com/fsnotify/fsnotify"
"github.com/tarm/serial eaafced92e9619f03c72527efeab21e326f3bc36"
"github.com/influxdata/influxdb 89e084a80fb1e0bf5e7d38038e3367f821fdf3d7"
"github.com/coreos/go-systemd 39ca1b05acc7ad1220e09f133283b8859a8b71ab"
)

inherit golang-build golang-vcs-snapshot

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="git://git.tizen.org/tools/muxpi"
	EGIT_CHECKOUT_DIR="${S}"
	inherit git-r3
	SRC_URI="${EGO_VENDOR_URI}"
else
	SRC_URI="http://download.tizen.org/slav/releases/muxpi-${PV}.tar.gz
		${EGO_VENDOR_URI}"
	KEYWORDS="~arm"
fi

DESCRIPTION="Flash Over The Air"
HOMEPAGE="https://wiki.tizen.org/MuxPi"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~arm"
IUSE=""

DEPEND=""
RDEPEND="sys-apps/stm"

src_unpack() {
	if [[ ${PV} == "9999" ]]; then
		git-r3_src_unpack
	else
		default_src_unpack
	fi
	golang-vcs-snapshot_src_unpack
}

src_compile() {
	set -- env GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)" GOARCH="${GOARCH:-$ARCH}" GOARM="${GOARM:-7}" go build -v -work -x -o bin/fota ${EGO_BUILD_FLAGS} "${EGO_PN}/cmd/fota"
	echo "$@"
	"$@" || die "compile failed"
}

src_install() {
	dobin bin/fota
}
