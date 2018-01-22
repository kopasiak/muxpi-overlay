# Copyright (c) 2018 Samsung Electronics Co., Ltd All Rights Reserved
# Distributed under the terms of the GNU General Public License v2

EAPI=6

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="git://git.tizen.org/tools/muxpi"
	EGIT_BRANCH="sandbox/amistewicz/conf"
	inherit git-r3
else
	SRC_URI="http://download.tizen.org/slav/releases/muxpi-${PV}.tar.gz"
	KEYWORDS="~arm"
fi

inherit systemd

DESCRIPTION="Configuration files for dryad"
HOMEPAGE="https://wiki.tizen.org/MuxPi"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

DEPEND="sys-apps/stm
	sys-apps/fota
	net-firewall/iptables"
RDEPEND="${DEPEND}"

src_install() {
	doins -r sw/nanopi/os/{etc,var}
	into /usr/local/
	dobin sw/nanopi/os/usr/local/bin/stm
	systemd_enable_service basic.target iptables-restore.service
}
