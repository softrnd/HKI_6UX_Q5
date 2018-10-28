# Add needed Freescale packages and definitions
SOC_TOOLS_TEST_mx6ul = "imx-test"
SOC_TOOLS_TEST_mx6ull = "imx-test"

# Install i.MX specific UAPI headers to rootfs
SOC_UAPI_HEADERS = "${@base_conditional('PREFERRED_PROVIDER_virtual/kernel','linux-mys6ulx','linux-mys6ulx-soc-headers','',d)}"

SOC_TOOLS_TESTAPPS_mx6ull += " \
    imx-kobs \
    vlan \
    cryptodev-module \
    cryptodev-tests \
    ${PN}-fslcodec-testapps \
"

