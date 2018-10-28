#! /bin/sh

imagedir=/run/media/mmcblk0p1/mfg-images
. ${imagedir}/Manifest
ubootfile=${imagedir}/${ubootfile}
envfile=${imagedir}/${envfile}
kernelfile=${imagedir}/${kernelfile}
dtbfile=${imagedir}/${dtbfile}
rootfsfile=${imagedir}/${rootfsfile}
datafile=${imagedir}/data.tar

echo "Update file list:"
echo "uboot file: ${ubootfile}"
echo "env file: ${envfile}"
echo "kernel file: ${kernelfile}"
echo "dtbfile file: ${dtbfile}"
echo "rootfs file: ${rootfsfile}"
echo "LED name: ${ledname}"

if echo ${ledname} | egrep -q '^[0-9]+$'; then
	echo "LED is GPIO"
	echo ${ledname} > /sys/class/gpio/export
	echo "out" > /sys/class/gpio/gpio${ledname}/direction
else
	echo "LED is name"
fi

bootpart=""
rootpart=""
datapart=""

LED_PID=""

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

cmd_check()
{
	if [ $1 -ne 0 ];then
		echo "$2 failed!"
		echo
		update_fail
	fi
}

check_file()
{
	if [ ! -s $1 ];then
		echo "invalid imagefile $1"
		echo
		update_fail
	fi
}

if grep "root" /proc/cmdline > /dev/null;then
	echo
	echo "***********************************************"
	echo "*************    SYSTEM UPDATE    *************"
	echo "***********************************************"
	echo
else
	echo "Normal boot"
	exit 0
fi

if echo ${ledname} | egrep -q '^[0-9]+$'; then
	update_start_gpioled &
	LED_PID=$!
else
	update_start_nameled &
	LED_PID=$!
fi

STEP=1
TOTAL_STEPS=10
if [ -s $datafile ];then
    TOTAL_STEPS=11
fi

echo -n "[ ${STEP} / ${TOTAL_STEPS} ] Check image files in $imagedir ... "
check_file $ubootfile
check_file $kernelfile
check_file $envfile
check_file $dtbfile
check_file $rootfsfilea
echo "OK"
echo

let STEP=STEP+1
echo -n "[ ${STEP} / ${TOTAL_STEPS} ] Checking Rootfs device: "
DRIVE="/dev/mmcblk1"
if grep "rootdev" /proc/cmdline > /dev/null;then
	ROOTDEV=`awk 'BEGIN{RS=" "} /rootdev/ {print}' /proc/cmdline |awk -F '=' '{print $2}'`
	if [ ! -z $ROOTDEV ];then
		DRIVE=$ROOTDEV
	fi
fi
echo "$DRIVE"
echo

let STEP=STEP+1
echo -n "[ ${STEP} / ${TOTAL_STEPS} ] Unmount all partitions in $DRIVE ... "
umount ${DRIVE}* > /dev/null 2>&1
echo OK
echo

dd if=/dev/zero of=${DRIVE} bs=1024 count=1 > /dev/null 2>&1
cmd_check $? "Destroy partition table"

SIZE=`fdisk -l $DRIVE | grep Disk | awk '{print $5}'`
echo -n "DISK SIZE: $SIZE bytes"

CYLINDERS=`echo $SIZE/255/63/512 | bc`
echo "CYLINDERS: $CYLINDERS"
echo

let STEP=STEP+1
echo "[ ${STEP} / ${TOTAL_STEPS} ] Re-partition device"
#{
#echo ,25,0x0C,*
#echo ,,,-
#} | sfdisk -D -H 255 -S 63 -C $CYLINDERS $DRIVE > /dev/null 2>&1
#} | sfdisk -D -H 255 -S 63 -C $CYLINDERS $DRIVE
sfdisk --force ${DRIVE} << EOF
10M,50M,0c
60M,,83
EOF
cmd_check $? "Re-partition device"
mdev -s > /dev/null 2>&1
umount ${DRIVE}* > /dev/null 2>&1
echo

let STEP=STEP+1
echo -n "[ ${STEP} / ${TOTAL_STEPS} ] Write u-boot ..."
dd if=/dev/zero of=${DRIVE} bs=1k seek=768 count=8 conv=fsync > /dev/null 2>&1
cmd_check $? "Clean u-boot arg"
echo 0 > /sys/class/block/mmcblk1boot0/force_ro
cmd_check $? "Write U-Boot to eMMC"
dd if=${ubootfile} of=${DRIVE}boot0 bs=512 seek=2 > /dev/null 2>&1
cmd_check $? "Update uboot"
echo 1 > /sys/class/block/mmcblk1boot0/force_ro
mmc bootpart enable 1 1 ${DRIVE}
cmd_check $? "Enable boot partion 1 to boot"

let STEP=STEP+1
echo -n "[ ${STEP} / ${TOTAL_STEPS} ] Formating boot partition ... "

if [ -b ${DRIVE}1 ]; then
	mkfs.fat -F 32 -n "boot" ${DRIVE}1 > /dev/null 2>&1
	cmd_check $? "Formating boot partition"
	bootpart=`basename ${DRIVE}1`
else
	if [ -b ${DRIVE}p1 ]; then
		mkfs.fat -F 32 -n "boot" ${DRIVE}p1 > /dev/null 2>&1
		cmd_check $? "Formating boot partition"
		bootpart=`basename ${DRIVE}p1`
	else
		echo "Cant find boot partition in ${DRIVE}1 or ${DRIVE}p1"
		echo
		update_fail
	fi
fi
echo OK
echo

let STEP=STEP+1
echo -n "[ ${STEP} / ${TOTAL_STEPS} ] Formating rootfs partition ... "

if [ -b ${DRIVE}2 ]; then
	mkfs.ext4 -F -L "rootfs" ${DRIVE}2 > /dev/null 2>&1
	cmd_check $? "Formating rootfs partition"
	rootpart=`basename ${DRIVE}2`
else
	if [ -b ${DRIVE}p2 ]; then
		mkfs.ext4 -F -L "rootfs" ${DRIVE}p2 > /dev/null 2>&1
		cmd_check $? "Formating rootfs partition"
		rootpart=`basename ${DRIVE}p2`
	else
		echo "Cant find rootfs partition in ${DRIVE}2 or ${DRIVE}p2"
		echo
		update_fail
	fi
fi
echo OK
echo

sleep 5

let STEP=STEP+1
echo -n "[ ${STEP} / ${TOTAL_STEPS} ] Copy boot files ... "
cp ${dtbfile} /run/media/${bootpart}
cmd_check $? "Copy ${dtbfile}"
cp ${envfile} /run/media/${bootpart}
cmd_check $? "Copy ${envfile}"
echo ${kernelfile}
cp ${kernelfile} /run/media/${bootpart}
cmd_check $? "Copy ${kernelfile}"
sync
umount /run/media/${bootpart}
echo OK
echo

let STEP=STEP+1
echo -n "[ ${STEP} / ${TOTAL_STEPS} ] Copy rootfs files ... "
mkdir -p /run/media/${rootpart}
mount -t ext4 -o rw,noatime,nodiratime /dev/${rootpart} /run/media/${rootpart} > /dev/null 2>&1
#cmd_check $? "mount ${rootpart}"
tar xvf ${rootfsfile} -C /run/media/${rootpart}
cmd_check $? "Extra ${rootfsfile}"
sync
umount /run/media/${rootpart}
echo OK
echo OK
echo

if [ -s ${datafile} ];then
	let STEP=STEP+1
	echo -n "[ ${STEP} / ${TOTAL_STEPS} ] Copy data files ... "
	mkdir -p /media/${datapart}
	mount -t ext4 -o rw,noatime,nodiratime /dev/${datapart} /media/${datapart} > /dev/null 2>&1
	cmd_check $? "mount ${datapart}"
	tar -xmf ${datafile} -C /media/${datapart} > /dev/null 2>&1
	cmd_check $? "Extra ${datafile}"
	sync
	umount /run/media/${datapart}
	echo OK
	echo
fi


echo "************************************************"
echo "********** System update successfully **********"
echo "************************************************"
echo

update_success

