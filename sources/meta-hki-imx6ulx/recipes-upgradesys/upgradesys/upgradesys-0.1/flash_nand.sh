#!/bin/sh
part_uboot=0
part_kernel=1
part_dtb=2
part_rootfs=3

LED_PID=""

mfg_path=/run/media/mmcblk0p1/mfg-images
if [ -f ${mfg_path}/Manifest ]
then
    . ${mfg_path}/Manifest
else
    echo "Can not find file ${mfg_path}Manifest"
    echo 0 > /sys/class/leds/cpu/brightness
    exit 1
fi
uboot=${mfg_path}/${ubootfile}
kernel=${mfg_path}/${kernelfile}
dtb=${mfg_path}/${dtbfile}
rootfs=${mfg_path}/${rootfsfile}

update_start_gpioled()
{
	echo "Update starting..."
	while true;do
		echo "Updating..."
		echo 1 > /sys/class/gpio/gpio${ledname}/value
		sleep 1
		echo "Updating..."
		echo 0 > /sys/class/gpio/gpio${ledname}/value
		sleep 1
	done
}

update_start_nameled()
{
	echo "Update starting..."
	echo heartbeat > /sys/class/leds/${ledname}/trigger
	while true;do
		echo "Updating..."
		sleep 1
	done
}


update_success()
{
	kill $LED_PID
	if echo ${ledname} | egrep -q '^[0-9]+$'; then
		echo 0 > /sys/class/gpio/gpio${ledname}/value
	else
		echo none > /sys/class/leds/${ledname}/trigger
		echo 1 > /sys/class/leds/${ledname}/brightness
	fi
	while true;do
		echo "Update complete..."
		sleep 1
		echo "Update complete..."
		sleep 1
	done
}


update_fail()
{
	kill $LED_PID
	if echo ${ledname} | egrep -q '^[0-9]+$'; then
		echo 1 > /sys/class/gpio/gpio${ledname}/value
	else
		echo none > /sys/class/leds/${ledname}/trigger
		echo 0 > /sys/class/leds/${ledname}/brightness
	fi

	while true;do
		echo "Update failed..."
		sleep 1
		echo "Update failed..."
		sleep 1
	done
}


if echo ${ledname} | egrep -q '^[0-9]+$'; then
	echo "LED is GPIO"
	echo ${ledname} > /sys/class/gpio/export
	echo "out" > /sys/class/gpio/gpio${ledname}/direction
	update_start_gpioled &
	LED_PID=$!
else
	echo "LED is ${ledname}"
	update_start_nameled &
	LED_PID=$!
fi

echo "Update file list:"
echo "uboot file: ${uboot}"
echo "kernel file: ${kernel}"
echo "dtb file: ${dtb}"
echo "rootfs file: ${rootfs}"

if [ -d $mfg_path ] && [ -s $uboot ] && [ -s $kernel ] && [ -s $dtb ] && [ -s $rootfs ]
then
    echo "prepare files are okay"
else
    echo "file or directory not exist"
    update_fail
    exit 1
fi

echo "Flashing uboot"
flash_erase /dev/mtd${part_uboot} 0 0 && kobs-ng init -x -v ${uboot}
if [ $? -eq 0 ]
then
    echo "Flash uboot okay"
else
    echo "Flash uboot failed"
    update_fail
    exit 1
fi

echo "Flashing kernel"
flash_erase /dev/mtd${part_kernel} 0 0 && nandwrite -p /dev/mtd${part_kernel} -p ${kernel}
if [ $? -eq 0 ]
then
    echo "Flash kernel okay"
else
    echo "Flash kernel failed"
    update_fail
    exit
fi
echo "Flashing dtb"
flash_erase /dev/mtd${part_dtb} 0 0 && nandwrite -p /dev/mtd${part_dtb} -p ${dtb}
if [ $? -eq 0 ]
then
    echo "Flash dtb file okay"
else
    echo "Flash dtb file failed"
    update_fail
    exit
fi

echo "Flashing kernel"
flash_erase /dev/mtd${part_rootfs} 0 0
if [ $? -ne 0 ]
then
    echo "erase /dev/mtd${part_rootfs} fail"
    update_fail
    exit
fi

ubiformat /dev/mtd${part_rootfs}
if [ $? -ne 0 ]
then
    echo "format /dev/mtd${part_rootfs} fail"
    update_fail
    exit
fi

ubiattach /dev/ubi_ctrl -m ${part_rootfs}
if [ $? -ne 0 ]
then
    echo "attach /dev/mtd${part_rootfs} fail"
    update_fail
    exit
fi

ubimkvol /dev/ubi0 -Nrootfs -m
if [ $? -ne 0 ]
then
    echo "make volume /dev/mtd${part_rootfs} fail"
    update_fail
    exit
fi

mkdir -p /run/media/mtd${part_rootfs} \
 && mount -t ubifs ubi0:rootfs /run/media/mtd${part_rootfs}
if [ $? -ne 0 ]
then
    echo "mount /dev/mtd${part_rootfs} fail"
    update_fail
    exit
fi

tar xvf ${rootfs} -C /run/media/mtd${part_rootfs}
if [ $? -eq 0 ]
then
	echo "Flash filesystem okay"
	sync && sync && sync
	umount /run/media/mtd${part_rootfs}
    	update_success
else
    echo "Flash filesystem failed"
    umount /run/media/mtd${part_rootfs}
    update_fail
    exit
fi
