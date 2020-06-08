# Arch Linux Setup Scripts

## Cindy Bui

This small repo is a collection of setup scripts to install Arch Linux on a hard drive with an encrypted boot and root partition. This loosely follows the instructions on how to do it in [Ubuntu](https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019) while using a lot of resources from the [Arch Wiki](https://wiki.archlinux.org). There are a total of 4 partitions - encrypted boot, unencrypted BIOS, unencrypted EFI, encrypted LVM with root and swap. These scripts were customized for me, so fair warning if you try to use them without looking at them.


## Usage
There will be a future blog post explaining the scripts in detail. In short,
- Use Rufus 
- Download these scripts somewhere accessible
- Edit the variables at the top of `chroot_install.sh` to your liking
- run `export DEV="/dev/<your-target-device>"`
- run `install.sh`
- Follow the prompts to enter the passphrases for encryption and passwords. The order is always the boot partition then the LVM partition.
- Optionally, run `graphics.sh` to install KDE Plasma afterwards


## Personal Setup
For clarification purposes, I have a laptop with two hard drives. I have a 500 GB NVMe drive that has a dual boot with Windows (/dev/nvme0n1p1-p5) and Ubuntu Studio (/dev/nvme0n1p6-p8). I have a second 1 TB 5400 RPM drive that came with my laptop that I put all of my data on (/dev/sda). My primary grub bootloader is on my Ubuntu Studio partition in /dev/nvme0n1p7, and the scripts are originally installed on /dev/sda. My target device was an external 160 GB hard drive at /dev/sdb.


## Resources
[Ubuntu Community - Full Disk Encryption Howto 2019](https://help.ubuntu.com/community/Full_Disk_Encryption_Howto_2019)

[Arch Wiki - Installation Guide](https://wiki.archlinux.org/index.php/Installation_guide)

[Arch Wiki - GRUB Encrypted boot](https://wiki.archlinux.org/index.php/GRUB#Encrypted_/boot)

[Arch Wiki - dm-crypt/System configuration](https://wiki.archlinux.org/index.php/Dm-crypt/System_configuration#cryptkey)

[Arch Wiki - mkinitcpio](https://wiki.archlinux.org/index.php/Mkinitcpio#BINARIES_and_FILES)

[Arch Wiki - dm-crypt/Device encryption](https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#With_a_keyfile_embedded_in_the_initramfs)

