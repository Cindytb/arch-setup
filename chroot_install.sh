#!/bin/bash

# Edit these variables as desired
HOSTNAME="arch-bui"
PRIMARY_GRUB_DEV="/dev/nvme0n1p7"
USERNAME="cindy"

# Throw an error and stop the script if something goes wrong
set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# Set the time and locale
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
sed -i 's/\#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set the hostname and /etc/hosts
echo $HOSTNAME > /etc/hostname

echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

# Install necessary packages for grub installation
pacman -S --noconfirm grub efibootmgr networkmanager lvm2 vi vim curl ufw sudo man-db man-pages texinfo

# Install grub
echo "GRUB_ENABLE_CRYPTODISK=y" >> /etc/default/grub
echo "GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(blkid -s UUID -o value ${DEV}5):encrypted_lvm\"" >> /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Installing networking and firewall
pacman -S --noconfirm networkmanager ufw

# Enable NetworkManager
systemctl enable NetworkManager.service

# Enable the firewall
systemctl enable ufw.service

# Create the key
mkinitcpio -p linux
dd if=/dev/urandom of=/crypto_keyfile.bin bs=4096 count=1
chmod 600 /crypto_keyfile.bin
chmod 600 /boot/initramfs-linux*

# Add keys to partitions
echo "Adding key to encrypted boot partition"
cryptsetup luksAddKey ${DEV}1 /crypto_keyfile.bin
echo "Adding key to encrypted LVM"
cryptsetup luksAddKey ${DEV}5 /crypto_keyfile.bin

# Add keys to crypttab
echo "encrypted_boot UUID=$(blkid -s UUID -o value ${DEV}1) /crypto_keyfile.bin luks,discard" >> /etc/crypttab
echo "encrypted_lvm UUID=$(blkid -s UUID -o value ${DEV}5) /crypto_keyfile.bin luks,discard" >> /etc/crypttab

# Edit the initramfs
sed -i 's|FILES=()|FILES=(/crypto_keyfile.bin)|' /etc/mkinitcpio.conf
sed -i 's/HOOKS=.*/HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck)/' /etc/mkinitcpio.conf
mkinitcpio -p linux

# Create a password
passwd

# Create a new user
useradd -m -G wheel $USERNAME
echo "Create a new password"
passwd $USERNAME

# Mount the other thing and add this to the grub
mkdir media
mount ${PRIMARY_GRUB_DEV} /media
vim /boot/grub/grub.cfg
