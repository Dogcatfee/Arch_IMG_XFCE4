#!/bin/bash

if [ "$1" != "" ]; then
    echo "Writing to device $1"
else
    echo "Supply a device ex: /dev/sdb"
    exit
fi

sudo umount $1*

#MBR partition table
printf 'o\nw\n' | sudo fdisk $1
#35M EFI partition
printf 'n\n\n\n\n+35M\nw\n' |  sudo fdisk $1
#Fill root partition
printf 'n\n\n\n\n\nw\n\n' | sudo fdisk $1
#Format EFI partition
sudo mkfs.fat $11
#Format root partition
sudo mkfs.ext4  $12
#Mount root partition
sudo mount  $12 ./work/x86_64/
#Make directories
sudo mkdir -p ./work/x86_64/boot/efi
#Mount EFI partition
sudo mount  $11 ./work/x86_64/boot/efi
#Run pacstrap with cache
#sudo pacstrap -c ./work/x86_64/ base
#Install from package list, includes AUR packages
sudo pacstrap -c -C pacman.conf ./work/x86_64/ $(cat ./packages.x86_64 && cat ./packages.both)
#Run customizations script in chroot
sudo arch-chroot ./work/x86_64/ < ./airootfs/root/customize_airootfs.sh
#Because customize has /dev/loop0 hardcoded
sudo arch-chroot ./work/x86_64/ grub-install --target=i386-pc $1
sudo arch-chroot ./work/x86_64/ grub-mkconfig -o /boot/grub/grub.cfg
sudo arch-chroot ./work/x86_64/ echo "fs0:\EFI\grub\grubx64.efi" >> /boot/efi/startup.nsh
#Cleanup
sudo umount  $11
sudo umount  $12
