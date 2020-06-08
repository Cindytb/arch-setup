#!/bin/bash

if [[ $DEV == "" ]]; then
    echo "ERROR: DEV variable is not set. Exiting"
    exit
fi

if ping -q -c 1 -W 1 8.8.8.8 > /dev/null; then
	echo 
else
	echo "ERROR: Bad internet connection"
	exit
fi
# Throw an error and stop the script if something goes wrong
set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# Wipe the drive completely (IRREVERSABLE)
sgdisk -Z $DEV 

# Create the partitions
sgdisk --new=1:0:+768M $DEV
sgdisk --new=2:0:+2M $DEV
sgdisk --new=3:0:+128M $DEV
sgdisk --new=5:0:0 $DEV

# Change the partition types
sgdisk --typecode=1:8301 --typecode=2:ef02 --typecode=3:ef00 --typecode=5:8301 $DEV
sgdisk --change-name=1:/boot --change-name=2:GRUB --change-name=3:EFI-SP --change-name=5:rootfs $DEV
sgdisk --hybrid 1:2:3 $DEV

# Encrypt the primary partitions
cryptsetup luksFormat --type=luks1 ${DEV}1
cryptsetup luksFormat --type=luks1 ${DEV}5

# Open the encrypted partitions and map them
cryptsetup open ${DEV}1 encrypted_boot
cryptsetup open ${DEV}5 encrypted_lvm

# format the partitions
mkfs.ext4 -L boot /dev/mapper/encrypted_boot
mkfs.vfat -F 16 -n EFI-SP ${DEV}3

# Create the LVM
pvcreate /dev/mapper/encrypted_lvm
vgcreate volume-group /dev/mapper/encrypted_lvm
lvcreate -L 16G -n swap volume-group
lvcreate -l 80%FREE -n root volume-group

# Encrypt the logical partitions
mkfs.ext4 /dev/mapper/volume--group-root
mkswap /dev/mapper/volume--group-swap
swapon /dev/mapper/volume--group-swap

# Mount the directory
mount /dev/mapper/volume--group-root /mnt
mkdir /mnt/efi
mkdir /mnt/boot
mount /dev/mapper/encrypted_boot /mnt/boot
mount /dev/sdb3 /mnt/efi

# Install arch linux
pacstrap /mnt base linux linux-firmware

# Create fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Copy the installation file into it
cp /media/arch/* /mnt/home

# Chroot into the new installation and continue the setup
arch-chroot /mnt /home/chroot_install.sh && /bin/bash
