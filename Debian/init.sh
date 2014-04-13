# Check Permissions
if [ $(whoami) != root ]; then
	echo "This script must be run as root."
	exit
fi

# Script Variables
NAME=debian
PATH=$(dirname $0)

# Enviroment Variables
export BIN=/system/bin
export HOME=/root
export MOUNT=/data/local/mnt/$NAME
export PATH=$BIN:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
export TERM=linux
export USER=root

# Change Directory
cd $PATH

# Create Mount Point
mkdir -p $MOUNT

# Remount System Read/Write
mount -o remount,rw /system

# Check Loop Block Device
if [ ! -b /dev/block/loop_$NAME ]; then
	# Create Loop Block Device
	mknod /dev/block/loop_$NAME b 7 255
fi

# Setup Loop Block Device
losetup /dev/block/loop_$NAME $NAME.img

# Mount Loop Block Device To Mount Point
mount -t ext2 /dev/block/loop_$NAME $MOUNT

# Add Mount Points
mount -o bind /dev $MOUNT/dev
mount -o bind /dev/pts $MOUNT/dev/pts
mount -o bind /dev/shm $MOUNT/dev/shm
mount -o bind /sdcard $MOUNT/media
mount -t proc none $MOUNT/proc
mount -t sysfs none $MOUNT/sys

# Set Options
echo "127.0.0.1 localhost" > $MOUNT/etc/hosts
echo "nameserver 8.8.4.4" > $MOUNT/etc/resolv.conf
echo "nameserver 8.8.8.8" >> $MOUNT/etc/resolv.conf
rm -rf $MOUNT/lost+found
sysctl -w net.ipv4.ip_forward=1 &> /dev/null
sysctl -w net.ipv6.conf.all.forwarding=1 &> /dev/null

# Enter Linux
chroot $MOUNT /bin/bash -c "source /etc/profile; bash"

# Remove Mount Points
umount $MOUNT/sys
umount $MOUNT/proc
umount $MOUNT/media
umount $MOUNT/dev/shm
umount $MOUNT/dev/pts
umount $MOUNT/dev

# Clean Up
umount $MOUNT
losetup -d /dev/block/loop_$NAME
rm /dev/block/loop_$NAME
rmdir $MOUNT
