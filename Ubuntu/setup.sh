# Check Permissions
if [ $(whoami) != root ]; then
	echo "This script must be run as root."
	exit
fi

# Script Variables
NAME=ubuntu
PATH=$(dirname $0)

# Change Directory
cd $PATH

# Create Image
dd if=/dev/zero of=$NAME.img bs=1M count=2048

# Format Image
mke2fs -F $NAME.img

# Set Image Filesystem Parameters
tune2fs -c 0 -i 0 -m 2 $NAME.img

# Create Mount Point
mkdir $NAME

# Mount Image
mount $NAME.img $NAME

# Download System Image
wget x

# Extract System Image
tar fvxz x

# Remove System Image
rm x

# Change Directory
cd $PATH

# Unmount Image
umount $NAME

# Remove Mount Point
rmdir $NAME
