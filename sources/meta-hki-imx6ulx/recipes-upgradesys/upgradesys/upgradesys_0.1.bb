#
# This package used for upgrade system for MYiR MYS6ULx board
#

SUMMARY = "Erasing and Flashing NAND script"
SECTION = "upgradesys"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " file://flash_nand.sh \
        file://flash_emmc.sh \
        file://linuxrc \
        file://S100update.sh"

S = "${WORKDIR}"
FILES_${PN} += "/linuxrc \
        /flash_nand.sh \
        /flash_emmc.sh \
        /S100update.sh"

do_install() {
	install -d ${D}${bindir}
	install -m 0777 flash_nand.sh ${D}${bindir}
	install -m 0777 flash_emmc.sh ${D}${bindir}
	install -m 0777 linuxrc ${D}
	install -d ${D}/${sysconfdir}/rc5.d
	install -m 0777 S100update.sh ${D}/${sysconfdir}/rc5.d
    
}
