# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PATCH_VER="1.3"
UCLIBC_VER="1.0"

# Hardened gcc 4 stuff
#PIE_VER="0.6.5"
#SPECS_VER="0.2.0"
#SPECS_GCC_VER="4.4.3"
# arch/libc configurations known to be stable with {PIE,SSP}-by-default
#PIE_GLIBC_STABLE="x86 amd64 mips ppc ppc64 arm ia64"
#PIE_UCLIBC_STABLE="x86 arm amd64 mips ppc ppc64"
#SSP_STABLE="amd64 x86 mips ppc ppc64 arm"
# uclibc need tls and nptl support for SSP support
# uclibc need to be >= 0.9.33
#SSP_UCLIBC_STABLE="x86 amd64 mips ppc ppc64 arm"
#end Hardened stuff

inherit eutils sabayon-toolchain

# This is here to redeclare is_gcc() in toolchain.eclass
# We don't even want to build gcj, which is a real hog
# on memory constrained hardware. base-gcc doesn't actually
# ship with it atm.
is_gcj() {
	return 1
}

DESCRIPTION="The GNU Compiler Collection"

KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"

RDEPEND="!!${CATEGORY}/gcc"
DEPEND="${RDEPEND}
	elibc_glibc? ( >=sys-libs/glibc-2.13 )
	>=${CATEGORY}/binutils-2.20"

## Do nothing!
pkg_preinst() {
	:
}

## Do nothing!
pkg_prerm() {
	:
}

## Do nothing!
pkg_postrm() {
	:
}
