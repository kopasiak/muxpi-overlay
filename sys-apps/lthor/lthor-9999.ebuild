# Copyright (c) 2018 Samsung Electronics Co., Ltd All Rights Reserved
# Distributed under the terms of the GNU General Public License v2

EAPI=6

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="git://git.tizen.org/tools/lthor"
	inherit git-r3
else
	SRC_URI="http://download.tizen.org/muxpi/releases/${P}.tar.gz"
	KEYWORDS="~arm"
fi

inherit cmake-utils

DESCRIPTION="Phone flashing tool"
HOMEPAGE="https://source.tizen.org/documentation/reference/flash-device"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND="app-arch/libarchive:0/13[bzip2,lzma,zlib]
	virtual/libusb:1"
RDEPEND="${DEPEND}"

pkg_postinst() {
	udevadm --reload-rules
}
