# Copyright (c) 2018 Samsung Electronics Co., Ltd All Rights Reserved
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="SDB client"
HOMEPAGE="https://wiki.tizen.org/SDK"
if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="git://git.tizen.org/sdk/tools/sdb"
	EGIT_BRANCH="tizen_studio"
	inherit git-r3
else
	MY_P="${PN}-56ba473f5b9afe5a5e0a3c13ddcf31b0bad618ad"
	SRC_URI="https://git.tizen.org/cgit/sdk/tools/sdb/snapshot/${MY_P}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~x86 ~amd64 ~arm"
	S="${WORKDIR}/${MY_P}"
fi
inherit epatch

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

RDEPEND="sys-libs/ncurses:5/5 dev-libs/openssl:0"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-Use-CHOST-variable.patch
	default
}
