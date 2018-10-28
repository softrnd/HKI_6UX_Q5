
inherit core-image
IMAGE_INSTALL = "imx-kobs \
    bzip2 \
    xz \
    gzip \
    mmc-utils \
    mtd-utils \
    mtd-utils-ubifs \
    upgradesys \
    rpm \
    bc \
    dosfstools \
    sysvinit \
    busybox \
    initscripts \
    shadow \
    shadow-base \
    sysvinit-inittab \
    e2fsprogs-mke2fs \
    util-linux-sfdisk \
    udev-extraconf \
    udev-rules-imx"

IMAGE_INSTALL_remove += "alsa python"
disable_service() {
    rm -f ${IMAGE_ROOTFS}${sysconfdir}/rc5.d/S01networking
    rm -f ${IMAGE_ROOTFS}${sysconfdir}/rc5.d/S22ofono
    rm -f ${IMAGE_ROOTFS}${sysconfdir}/rc5.d/S64neard
    rm -f ${IMAGE_ROOTFS}${sysconfdir}/rc5.d/S99stop-bootlogd
}
ROOTFS_POSTUNINSTALL_COMMAND += "disable_service; "
IMAGE_FSTYPES = "ext4 tar.xz ext4.gz "
