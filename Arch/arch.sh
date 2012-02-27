# Change Directory
name=arch
path=/sdcard/Linux/Arch
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

# Make Image
if [ ! -f $name.img ]; then
	dd if=/dev/zero of=$name.img bs=1024 count=2097152
	mke2fs -F $name.img
	tune2fs -c 0 -i 0 -m 2 $name.img
	installed=true
fi

# Install Image
if [ "$installed" == "true" ]; then
	cd $mnt
	wget http://www.archlinuxarm.org/os/ArchLinuxARM-armv5te-latest.tar.gz
	tar fvxz ArchLinuxARM-armv5te-*.tar.gz
	rm ArchLinuxARM-armv5te-*.tar.gz
	cd $path
fi

# Mount Image
if [ ! -b /dev/block/loop255 ]; then
	mknod /dev/block/loop255 b 7 255
fi
losetup /dev/block/loop255 $name.img
mount -t ext2 /dev/block/loop255 $mnt

# Mount Paths
mount -o bind /dev $mnt/dev
mount -o bind /dev/pts $mnt/dev/pts
mount -o bind /dev/shm $mnt/dev/shm
mount -o bind /sdcard $mnt/media
mount -t proc none $mnt/proc
mount -t sysfs none $mnt/sys

# Set Options
sysctl -w net.ipv4.ip_forward=1 > /dev/null
sysctl -w net.ipv6.ip_forward=1 > /dev/null
echo "127.0.0.1 localhost" > $mnt/etc/hosts
echo "nameserver 8.8.8.8" > $mnt/etc/resolv.conf

# Enter Linux
rm -rf $mnt/lost+found
chroot $mnt /bin/bash -c "source /etc/profile; bash"

# Exit Linux
umount $mnt/sys
umount $mnt/proc
umount $mnt/media
umount $mnt/dev/shm
umount $mnt/dev/pts
umount $mnt/dev

# Clean Up
umount $mnt
losetup -d /dev/block/loop255
rm /dev/block/loop255
rmdir $mnt
