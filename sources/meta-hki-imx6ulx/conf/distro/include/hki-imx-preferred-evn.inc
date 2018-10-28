# Use i.MX Kernel, U-Boot and Gstreamer 1.0 providers
PREFERRED_PROVIDER_u-boot_mx6ul = "u-boot-mys6ulx"
PREFERRED_PROVIDER_u-boot_mx6ull = "u-boot-mys6ulx"

PREFERRED_PROVIDER_virtual/bootloader_mx6ul = "u-boot-mys6ulx"
PREFERRED_PROVIDER_virtual/bootloader_mx6ull = "u-boot-mys6ulx"

PREFERRED_PROVIDER_virtual/kernel_mx6ul = "linux-mys6ulx"
PREFERRED_PROVIDER_virtual/kernel_mx6ull = "linux-mys6ulx"

MACHINE_GSTREAMER_1_0_PLUGIN_mx6ul = "imx-gst1.0-plugin"
MACHINE_GSTREAMER_1_0_PLUGIN_mx6ull = "imx-gst1.0-plugin"

# Extra audio support
# Add back some setting for i.MX6ul & i.MX7d which have not been upstreamed
MACHINE_EXTRA_RRECOMMENDS_append_mx6ul = " ${@bb.utils.contains('DISTRO_FEATURES', 'alsa', 'imx-alsa-plugins', '', d)}"

# Default toolchains used in testing i.MX BSPs
DEFAULTTUNE_mx6ul = "cortexa7hf-neon"

# Enable the kenrel loadable module as default
#USE_GPU_VIV_MODULE = "1"

PREFERRED_VERSION_linux-libc-headers = "4.1"

# Use systemd as default init manager - comment out for now
#VIRTUAL-RUNTIME_init_manager = "systemd"
#PREFERRED_PROVIDER_udev = "systemd"
#PREFERRED_PROVIDER_udev-utils = "systemd"
#DISTRO_FEATURES_BACKFILL_CONSIDERED = "sysvinit"
#IMX_DEFAULT_DISTRO_FEATURES += " systemd"

GCCVERSION = "5.3.0"
