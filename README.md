This guide describes how to use, work with and make muxpi-overlay. Some parts are short
introductions to aspects of Gentoo system and can be safely skipped by an experienced Gentoo user.
In this document `/usr/armv7a-hardfloat-linux-gnueabi/` will be assumed ROOT prefix.

# Use
This section describes how to use created distribution image.

Everything is cross-compiled on a powerful x86\_64 machine. No package is compiled in chroot or on
NanoPi. Compiler is not built at all. It means that the only way for an installation to get
updates is a BINHOST (<https://wiki.gentoo.org/wiki/Binary_package_guide#Using_binary_packages>).
Distributed image comes with `FEATURES="getbinpkg"` what means that `portage` will attempt to fetch
binary packages from URL pointed by a list in `PORTAGE_BINHOST`. Both parameters are set in
`/etc/portage/make.conf` (and the corresponding configuration from profile -
`/etc/portage/make.profile`).

## Portage
Provided distribution is minimal. Therefore it is missing some files, like portage repository
(usually stored in `/usr/portage`). It can be populated by running `emerge --sync`. It will pull the
official Gentoo git repository. It may take a very long time so in a typical setup it is recommended
to mount it (using NFS or curlftpfs) or use squashfs snapshot
(<https://www.brunsware.de/blog/gentoo/portage-tree-squashfs-overlayfs.html>). The same applies to the
overlay. The usual call to `emerge -NuDa @world` should upgrade the system using binary packages.
`/var/lib/portage/world` contains the list of packages that the user wants on their system. Packages
outside of this set can be removed using `emerge --depclean --ask`.

## Overlay
What is an overlay?
<https://wiki.gentoo.org/wiki/Ebuild_repository>

Muxpi-overlay consists of:
 * modified ebuilds from open source projects (Gentoo and Sabayon),
 * new ebuilds for kernel and utilities residing on download.tizen.org,
 * new ebuilds for other utilities required by SLAV project,
 * profile definition with some useful defaults.

It can be installed by creating a file `/etc/portage/repos.conf/nanopi.conf` with the following
content:

    [nanopi]
    location = /usr/local/src/muxpi-overlay
    sync-type = git
    sync-uri = git://git.tizen.org/tools/muxpi-overlay
    auto-sync = yes

Call `emerge --sync` to populate repositories.

This overlay is using `thin-manifests = true`, because it is assumed that VCS provides sufficient
level of verification.

### Layman
It is planned to make it possible to install overlay easily with layman.
<https://wiki.gentoo.org/wiki/Layman#Usage>

## Profile
Most configuration is kept in the `nanopi:default/linux/arm/17.0/armv7a/nanopi` profile available
from the overlay. It resides in `profiles/default/linux/arm/17.0/armv7a/nanopi` in the repository
and consists of the following files:
 * eapi - minimal acceptable EAPI version,
 * make.defaults - default configuration of portage,
 * package.mask - package and version masks,
 * package.use - USE flag definitions,
 * parent - profiles it inherits from.

## Package versions
Packages with `-9999` correspond to "development" versions. They are usually built using the sources
residing in some kind of VCS. When software is released, a tarball is published and the ebuild is
updated to match the version. It uses the tarball which is verified using Manifest files. When the
version of the package is declared stable, the keyword is changed, for example from ~amd64 to amd64.

It is the user who chooses the version of installed packages. It can be done by specifying
the package atom, for example:

    emerge -av1 "=sys-devel/gcc-6.4.0-r1"

Alternatively some versions may be masked by the user in `/etc/portage/package.mask`:

    >sys-devel/gcc-6.4.0-r1

In this example all versions above 6.4.0-r1 will be masked and the most recent non-masked version
will be automatically chosen. Package keywords work similarly.


# Work
This section describes how to use muxpi-overlay in order to create an operating system image. The
reader should follow Gentoo Wiki guides regarding the topic:
 * guide to creating a cross-compile environment
    <https://wiki.gentoo.org/wiki/Cross_build_environment>
    <https://wiki.gentoo.org/wiki/Custom_repository#Crossdev>
 * crossdev used by sunxi
    <https://linux-sunxi.org/Toolchain#Gentoo>

## Build

1. Mount or copy overlay to proper directories.
2. Select profile from an overlay. Take note that the `make.profile` symlink to the profile must be
   absolute to avoid build issues.
3. Build the base system:

        armv7a-hardfloat-linux-gnueabi-emerge -av @system

4. Create a list of packages that the user wants installed on the system in
`/usr/armv7a-hardfloat-linux-gnueabi/var/lib/portage/world`. For example:

        app-admin/sudo
        app-misc/tmux
        dev-tcltk/expect
        dev-util/android-tools
        net-fs/sshfs
        sys-apps/fota
        sys-apps/sdb
        sys-apps/stm
        sys-conf/dryad

5. Build the rest of the system:

        armv7a-hardfloat-linux-gnueabi-emerge -av @world

You can also create missing directories and symlink as required by systemd (or to fix some python
installations on 64-bit build systems):

    mkdir /usr/armv7a-hardfloat-linux-gnueabi/{proc,dev,sys,boot,home,media,mnt,opt,srv}
    ln -s /run /usr/armv7a-hardfloat-linux-gnueabi/var/run
    ln -s /lib /usr/armv7a-hardfloat-linux-gnueabi/lib64
    ln -s /usr/lib /usr/armv7a-hardfloat-linux-gnueabi/usr/lib64

It may be necessary to build `sys-apps/util-linux` with some flags disabled (to avoid unresolved
cycle dependency):

    USE="-systemd -udev" armv7a-hardfloat-linux-gnueabi-emerge -av1 sys-apps/util-linux

The issue was also encountered with `sys-process/procps`.

Please note that `armv7a-hardfloat-linux-gnueabi-emerge` installs packages in ROOT prefix only.
Therefore, some builds that require certain tools during the build process may fail. One such
package is `sys-apps/systemd` which is dependent on `ninja` and `meson`. To install all build-time
dependencies issue the following command:

    USE="-acl -gcrypt -lz4 -pam" emerge --onlydeps-with-rdeps=n -oavt systemd

Among packages requiring a similar workaround are also `dev-tcltk/expect` and Go-based SLAV stack
components such as `sys-apps/stm`.

Some packages may warn that kernel configuration was not found or is incorrect. It can be fixed by
pointing to the location of kernel sources with symlink
`/usr/armv7a-hardfloat-linux-gnueabi/usr/src/linux`.

As it has been noted in Gentoo Wiki article, remember to copy `/etc/passwd`, `/etc/shadow` and
`/etc/group` or hardlink these files to build system versions.

## Upgrade
Call `armv7a-hardfloat-linux-gnueabi-emerge -uDN @world` to upgrade ROOT prefix.

## Minimal installation
Though, `sys-devel/gcc` takes under 100MB of diskspace, it is not necessary to have it installed.
It can be uninstalled and replaced by `sys-devel/base-gcc`. Profile is set to provide
`sys-devel/gcc` and warning will be printed every time @system target is specified. When migrating
live system after `emerge --unmerge sys-devel/gcc` many programs may break so `emerge
sys-devel/base-gcc` should be called immediately after that.

## Binhost
Profile has `FEATURES` set for building binary packages automatically. Files that should be shared
are stored in `/usr/armv7a-hardfloat-linux-gnueabi/packages/` or other directory pointed by
`PKGDIR`. In order to build a package without installing it use `--buildpkgonly` or `-B` options
when calling `armv7a-hardfloat-linux-gnueabi-emerge`.

## Kernel
The overlay provides the ebuild for kernel used on NanoPi. The sources can be installed with the
command:

    emerge -av1 sys-kernel/sunxi-sources

Then navigate to the `/usr/src/linux-4.11-rc1/`.

1. Configure:

        make ARCH=arm CROSS_COMPILE=armv7a-hardfloat-linux-gnueabi- menuconfig

2. Build:

        make ARCH=arm CROSS_COMPILE=armv7a-hardfloat-linux-gnueabi- -j9

3. Copy files to boot partition:

        cp arch/arm/boot/zImage arch/arm/boot/dts/sun8i-h3-nanopi-neo.dtb /boot-partition-moutpoint/

## Create distribution image
It is possible to create ext4 image directly:

    truncate rootfs.ext4
    mkfs.ext4 -d /usr/armv7a-hardfloat-linux-gnueabi rootfs.ext4

It is easier to upgrade the image and modify it automatically using rsync. Create XFS image similar
to the example above:

    truncate -s 800M rootfs.xfs
    mkfs.xfs rootfs.xfs

The following files configure the contents of the image and are useful for updates.

/workdir/update_rootfs.sh:

    #!/bin/sh
    mount -o loop /workdir/rootfs.xfs /root/m
    rsync -av --exclude-from=/workdir/rootfs.exclude --delete /usr/armv7a-hardfloat-linux-gnueabi/
    /root/m
    rsync -av /workdir/rootfs-overlay/ /root/m/
    umount /root/m

/workdir/rootfs.exclude:

    packages
    sys-include
    workdir
    tmp
    sys
    proc
    dev
    usr/local/bin/qemu-wrapper
    usr/bin/qemu-arm
    root/
    etc/portage/make.conf

Naturally, `/workdir/rootfs-overlay` contains all files that should be replaced. For instance,
`/etc/portage/make.conf` - configuration suitable for a binary host - should be replaced with values
for installation using binary packages.

## Configuration

Enable services. It can be done by symlinking proper files or calling `systemctl enable` in chroot.

    ln -s ../../../../lib/systemd/system/sshd.service /usr/armv7a-hardfloat-linux-gnueabi/etc/systemd/system/multi-user.target.wants/sshd.service
    ln -s ../../../../lib/systemd/system/serial-getty@.service /usr/armv7a-hardfloat-linux-gnueabi/etc/systemd/system/getty.target.wants/serial-getty@ttyS0.service
    ln -s ../../../../lib/systemd/system/systemd-networkd.service /usr/armv7a-hardfloat-linux-gnueabi/etc/systemd/system/multi-user.target.wants/systemd-networkd.service
    ln -s ../../../../lib/systemd/system/systemd-resolved.service /usr/armv7a-hardfloat-linux-gnueabi/etc/systemd/system/multi-user.target.wants/systemd-resolved.service

Set locale, timezone and `/etc/fstab` if necessary.

### Compress
Image compresses really well. Running `lzma -k -9 rootfs.xfs` results in file of 83M in size.


# Make
This section describes how to create muxpi-overlay. Most is described in Gentoo Wiki:
 * guide to understanding ebuild
    <https://devmanual.gentoo.org/ebuild-writing/functions/>
    <https://devmanual.gentoo.org/function-reference/install-functions/>
 * guide to writing ebuilds
    <https://devmanual.gentoo.org/ebuild-writing/>
 * guide to understanding metadata.xml
    <https://devmanual.gentoo.org/ebuild-writing/misc-files/metadata/index.html>
 * list of eclasses helpful in writing ebuilds
    <https://devmanual.gentoo.org/eclass-reference/index.html>

## Environment
It is recommended to use the regular Gentoo distribution. However, it is possible to do every step
described here in Docker container. `--privileged` is required for loopback mounts and binfmt to
work. `--cap-add=SYS_PTRACE` is added per recommendation from a blog
(<https://blogs.gentoo.org/marecki/2017/03/17/gentoo-linux-in-a-docker-container/>). Command is:

    docker run --privileged -v ~/nanopi-gentoo-docker/:/workdir \
        --name gentoo-privileged --cap-add=SYS_PTRACE -it \
        gentoo/stage3-amd64 /bin/bash
