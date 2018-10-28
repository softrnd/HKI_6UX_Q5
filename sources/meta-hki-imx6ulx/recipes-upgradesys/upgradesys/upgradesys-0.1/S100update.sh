#!/bin/sh
### BEGIN INIT INFO
# Provides: banner
# Required-Start:
# Required-Stop:
# Default-Start:     S
# Default-Stop:
### END INIT INFO

echo "System update start ..."
if grep "update_emmc" /proc/cmdline > /dev/null;then
    echo "Update for eMMC flash"
	flash_emmc.sh
elif grep "update_nand" /proc/cmdline > /dev/null;then
    echo "Update for NAND flash"
	flash_nand.sh
else
    echo "Update failed! Please restart and enter update process."
    exit 0
fi
