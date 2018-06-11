# Copyright (c) 2018 Samsung Electronics Co., Ltd All Rights Reserved
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="git.tizen.org/tools/boruta"
S=${WORKDIR}/${P}/src/${EGO_PN}

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="git://git.tizen.org/tools/boruta"
	EGIT_CHECKOUT_DIR="${S}"
	inherit git-r3
else
	SRC_URI="http://download.tizen.org/slav/releases/boruta-${PV}.tar.gz"
	KEYWORDS="~arm"
fi

inherit golang-build user systemd

DESCRIPTION="Service connecting to Boruta server"
HOMEPAGE="https://wiki.tizen.org/MuxPi"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~arm"
IUSE=""

DEPEND="sys-apps/stm"
RDEPEND=""

src_prepare() {
	default_src_prepare
	set -- env GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)" go get -v -d "${EGO_PN}/cmd/dryad"
	echo "$@"
	"$@" || die "dependency fetch failed"
}

src_compile() {
	set -- env GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)" GOARCH="${GOARCH:-$ARCH}" GOARM="${GOARM:-7}" go build -v -x -o bin/dryad ${EGO_BUILD_FLAGS} "${EGO_PN}/cmd/dryad"
	echo "$@"
	"$@" || die "compile failed"
}

src_install() {
	dobin bin/dryad
}
