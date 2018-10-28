# Provides the i.MX common settings

include conf/machine/include/fsl-default-settings.inc
include conf/machine/include/fsl-default-versions.inc

include conf/machine/include/soc-family.inc

# Set specific make target and binary suffix
PREFERRED_PROVIDER_u-boot ??= "u-boot-mys6ulx"
PREFERRED_PROVIDER_virtual/bootloader ??= "u-boot-mys6ulx"

UBOOT_MAKE_TARGET ?= "u-boot.imx"

UBOOT_SUFFIX ?= "imx"

UBOOT_ENTRYPOINT_mx6ul  = "0x10008000"

PREFERRED_PROVIDER_virtual/xserver = "xserver-xorg"
XSERVER_DRIVER = "xf86-video-fbdev"
XSERVER_DRIVER_mx6 = "xf86-video-imxfb-vivante"
XSERVER_DRIVER_vf = "xf86-video-modesetting"
XSERVER = "xserver-xorg \
           xf86-input-evdev \
           ${XSERVER_DRIVER}"

# Ship kernel modules
MACHINE_EXTRA_RRECOMMENDS = "kernel-modules"

# Tunes for hard/soft float-point selection. Note that we allow building for
# thumb support giving distros the chance to enable thumb by setting
# ARM_INSTRUCTION_SET = "thumb"
#
# handled by software
# DEFAULTTUNE_mx6 ?= "cortexa9t-neon"
# handled by hardware
DEFAULTTUNE_mx6 ?= "cortexa9thf-neon"
DEFAULTTUNE_mx6ul ?= "cortexa7thf-neon"

# Sub-architecture support
MACHINE_SOCARCH_SUFFIX ?= ""
MACHINE_SOCARCH_SUFFIX_mx6ul = "-mx6ul"
MACHINE_SOCARCH_SUFFIX_mx6ull = "-mx6ull"

MACHINE_ARCH_FILTER = "virtual/kernel"
MACHINE_SOCARCH_FILTER_append_mx6 = " imx-vpu libimxvpuapi imx-codec imx-vpuwrap imx-parser"
MACHINE_SOCARCH_FILTER_append_mx6 = " virtual/libopenvg virtual/libgles1 virtual/libgles2 virtual/egl virtual/mesa virtual/libgl virtual/libg2d"
MACHINE_SOCARCH_FILTER_append_mx6ul = " imx-codec imx-parser"
MACHINE_SOCARCH_FILTER_append_mx7 =  " imx-codec imx-parser"

INHERIT += "fsl-dynamic-packagearch"

SIGGEN_EXCLUDE_SAFE_RECIPE_DEPS_append_mx6 = " \
    imx-gpu-viv->kernel-module-imx-gpu-viv \
    libimxvpuapi->imx-vpu \
    imx-vpuwrap->imx-vpu \
    imx-codec->imx-vpu \
    imx-test->imx-vpu \
"

# Firmware
MACHINE_FIRMWARE ?= ""
MACHINE_FIRMWARE_append_mx6ul = ""
MACHINE_FIRMWARE_append_mx6ull = ""
MACHINE_FIRMWARE_append_mx6q = " firmware-imx-vpu-imx6q"
MACHINE_FIRMWARE_append_mx6dl = " firmware-imx-vpu-imx6d firmware-imx-epdc"

MACHINE_EXTRA_RRECOMMENDS += "${MACHINE_FIRMWARE}"

# Extra audio support
# FIXME: Add support for ALL SoC families
MACHINE_EXTRA_RRECOMMENDS_append_mx6 = " ${@bb.utils.contains('DISTRO_FEATURES', 'alsa', 'imx-alsa-plugins', '', d)}"

# Extra udev rules
MACHINE_EXTRA_RRECOMMENDS += "udev-rules-imx"

# GStreamer 1.0 plugins
MACHINE_GSTREAMER_1_0_PLUGIN ?= ""

# Determines if the SoC has support for Vivante kernel driver
SOC_HAS_VIVANTE_KERNEL_DRIVER_SUPPORT       = "0"

# Handle Vivante kernel driver setting:
#   0 - machine does not have Vivante GPU driver support
#   1 - machine has Vivante GPU driver support
MACHINE_HAS_VIVANTE_KERNEL_DRIVER_SUPPORT ?= "${SOC_HAS_VIVANTE_KERNEL_DRIVER_SUPPORT}"

# mx6 GPU libraries
PREFERRED_PROVIDER_virtual/egl_mx6ul ?= "mesa"
PREFERRED_PROVIDER_virtual/libgles1_mx6ul ?= "mesa"
PREFERRED_PROVIDER_virtual/libgles2_mx6ul ?= "mesa"
PREFERRED_PROVIDER_virtual/libgl_mx6ul ?= "mesa"
PREFERRED_PROVIDER_virtual/libg2d_mx6ul = ""

# Handle default kernel
IMX_DEFAULT_KERNEL = "linux-mys6ulx"
IMX_DEFAULT_KERNEL_mx6ul = "linux-mys6ulx"
IMX_DEFAULT_KERNEL_mx6ull = "linux-mys6ulx"

PREFERRED_PROVIDER_virtual/kernel ??= "${IMX_DEFAULT_KERNEL}"

SOC_DEFAULT_IMAGE_FSTYPES = "sdcard.gz ext3 ubi ubifs"

SDCARD_ROOTFS ?= "${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.rootfs.ext4"
IMAGE_FSTYPES ?= "${SOC_DEFAULT_IMAGE_FSTYPES}"

SERIAL_CONSOLE = "115200 ttymxc0"

KERNEL_IMAGETYPE = "zImage"

MACHINE_FEATURES = "apm usbgadget usbhost vfat alsa touchscreen"

# Add the ability to specify _imx machines
MACHINEOVERRIDES =. "imx:"
