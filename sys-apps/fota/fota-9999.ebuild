# Copyright (c) 2018 Samsung Electronics Co., Ltd All Rights Reserved
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGO_PN="git.tizen.org/tools/muxpi"
S=${WORKDIR}/${P}/src/${EGO_PN}

inherit golang-build

DESCRIPTION="Flash Over The Air"
HOMEPAGE="https://wiki.tizen.org/MuxPi"
EGIT_REPO_URI="git://git.tizen.org/tools/muxpi"
EGIT_CHECKOUT_DIR="${S}"
inherit git-r3

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~arm"
IUSE=""

DEPEND=""
RDEPEND="sys-apps/stm"

src_prepare() {
	default_src_prepare
	set -- env GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)" go get -v -d "${EGO_PN}/sw/nanopi/..."
	echo "$@"
	"$@" || die "dependency fetch failed"
}

src_compile() {
	set -- env GOPATH="${WORKDIR}/${P}:$(get_golibdir_gopath)" GOARCH="${GOARCH:-$ARCH}" GOARM="${GOARM:-7}" go build -v -work -x -o bin/fota ${EGO_BUILD_FLAGS} "${EGO_PN}/sw/nanopi/cmd/fota"
	echo "$@"
	"$@" || die "compile failed"
}

src_install() {
	dobin bin/fota
}
