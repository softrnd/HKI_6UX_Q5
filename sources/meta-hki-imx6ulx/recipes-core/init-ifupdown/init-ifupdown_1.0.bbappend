FILESEXTRAPATHS_prepend := "${THISDIR}/${BP}:"

SRC_URI += "file://interface.ppp0"

do_install_append() {
    cat ${WORKDIR}/interface.ppp0 >> ${D}${sysconfdir}/network/interfaces
}
