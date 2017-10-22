#!/bin/bash

mkdir -p ./work/x86_64
#Run pacstrap with cache
#Install from package list, includes AUR packages
sudo pacstrap -c -C pacman.conf ./work/x86_64/ $(cat ./packages.x86_64 && cat ./packages.both)
#Run customizations script in chroot
sudo arch-chroot ./work/x86_64/ < ./airootfs/root/customize_airootfs.sh
#Because customize has /dev/loop0 hardcoded
sudo arch-chroot ./work/x86_64/ grub-install 
sudo arch-chroot ./work/x86_64/ grub-mkconfig -o /boot/grub/grub.cfg
