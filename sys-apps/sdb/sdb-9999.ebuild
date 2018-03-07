# Copyright (c) 2018 Samsung Electronics Co., Ltd All Rights Reserved
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="SDB client"
HOMEPAGE="https://wiki.tizen.org/SDK"
EGIT_REPO_URI="git://git.tizen.org/sdk/tools/sdb"
EGIT_BRANCH="tizen_studio"
inherit epatch git-r3

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~arm"
IUSE=""

RDEPEND="sys-libs/ncurses:5/5 dev-libs/openssl:0"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-Use-CHOST-variable.patch
	default
}
