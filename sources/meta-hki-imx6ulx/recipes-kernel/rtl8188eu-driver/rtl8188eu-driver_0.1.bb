SUMMARY = "wifi driver for RTL8188EU on MYS6ULx board"
LICENSE = "GPLv2"
PV = "0.1"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

inherit module

SRCREV = "5cfd9b9323e774dd8ee75a9523bd6a3f9d467cb6"
SRC_URI = "git://github.com/MYiR-Dev/RTL8188eu-driver;protocol=https;branch=master"
S = "${WORKDIR}/git"
FILES_${PN} = "${base_libdir}/firmware/rtlwifi"

do_install_append() {
    install -d ${D}${base_libdir}/firmware/rtlwifi
    install -m 0755 rtl8188eufw.bin ${D}${base_libdir}/firmware/rtlwifi/
}

# The inherit of module.bbclass will automatically name module packages with
# "kernel-module-" prefix as required by the oe-core build environment.
