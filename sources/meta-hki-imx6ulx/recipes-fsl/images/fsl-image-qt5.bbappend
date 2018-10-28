DESCRIPTION = "Freescale Image - Adds Qt5"
LICENSE = "MIT"
inherit populate_sdk_qt5

# require recipes-fsl/images/fsl-image-qt5-validation-imx.bb

IMAGE_INSTALL += " \
    imx-kobs \
    tslib-calibrate \
    tslib-conf \
    tslib-tests \
    bzip2 \
    gzip \
    canutils \
    dosfstools \
    mtd-utils \
    mtd-utils-ubifs \
    ntpdate \
    vlan \
    tar \
    net-tools \
    ethtool \
    evtest \
    i2c-tools \
    iperf3 \
    iproute2 \
    iputils \
    udev-extraconf \
    iperf \
    openssl \
    v4l-utils \
    alsa-utils \
    ppp \
    ppp-quectel \
    myir-rc-local \
"
