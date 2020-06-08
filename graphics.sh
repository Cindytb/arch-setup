#!/bin/bash
# This is an optional script to install KDE Plasma. Run it after the installation is finished

# Throw an error and stop the script if something goes wrong
set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

# Graphics and desktop environment
pacman -S --noconfirm xorg-server xf86-video-nouveau xf86-video-intel sddm plasma

# Enable SDDM
systemctl enable sddm.service
