# Change Directory
name=ubuntu
path=/sdcard/Linux/Ubuntu
cd $path

# Check Permissions
if [ $(whoami) != root ]; then
	echo "This script must be run as root."
	exit
fi

# Variables
export bin=/system/bin
export mnt=/data/local/mnt/$name
export HOME=/root
export PATH=$bin:/bin:/sbin:/usr/bin:/usr/games:/usr/local/bin:/usr/local/sbin:$PATH
export TERM=linux
export USER=root

# Mount System
mount -o remount,rw /dev/block/mmcblk0p5 /system
mkdir $mnt

# Mount Image
if [ ! -b /dev/block/loop255 ]; then
	mknod /dev/block/loop255 b 7 255
fi
losetup /dev/block/loop255 $name.img
mount -t ext2 /dev/block/loop255 $mnt

# Mount Paths
mount -o bind /sdcard $mnt/sdcard
mount -t devpts devpts $mnt/dev/pts
mount -t proc proc $mnt/proc
mount -t sysfs sysfs $mnt/sys

# Set Options
sysctl -w net.ipv4.ip_forward=1 > /dev/null
sysctl -w net.ipv6.ip_forward=1 > /dev/null
echo "127.0.0.1 localhost" > $mnt/etc/hosts
echo "nameserver 8.8.8.8" > $mnt/etc/resolv.conf

# Enter Linux
rm -rf $mnt/lost+found
chroot $mnt /root/init.sh

# Exit Linux
umount $mnt/sys
umount $mnt/proc
umount $mnt/dev/pts
umount $mnt/sdcard

# Clean Up
umount $mnt
losetup -d /dev/block/loop255
rm /dev/block/loop255
rmdir $mnt
