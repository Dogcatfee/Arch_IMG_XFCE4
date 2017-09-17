#!/bin/bash

image_name=production_disk


#1.5G disk, Modify to build bigger badder disks
#dd if=/dev/urandom of=$image_name.img bs=4M count=360 && sync
#4.5G disk, Modify to build bigger badder disks
dd if=/dev/urandom of=$image_name.img bs=4M count=1080 && sync

#MBR partition table
printf 'o\nw\n' | sudo fdisk ./$image_name.img
#35M EFI partition
printf 'n\n\n\n\n+35M\nw\n' |  sudo fdisk ./$image_name.img
#Fill root partition
printf 'n\n\n\n\n\nw\n\n' | sudo fdisk ./$image_name.img
#Loop disk up with partition support
sudo losetup -P /dev/loop0 ./$image_name.img
#Format EFI partition
sudo mkfs.fat /dev/loop0p1
#Format root partition
sudo mkfs.ext4 /dev/loop0p2
#Mount root partition
sudo mount /dev/loop0p2 ./work/x86_64/
#Make directories
sudo mkdir -p ./work/x86_64/boot/efi
#Mount EFI partition
sudo mount /dev/loop0p1 ./work/x86_64/boot/efi
#Run pacstrap with cache
sudo pacstrap -c ./work/x86_64/ -C ./pacman.conf
#Install from package list, includes AUR packages
sudo pacstrap -c -C pacman.conf ./work/x86_64/ $(cat ./packages.x86_64 && cat ./packages.both)
#Run customizations script in chroot
sudo arch-chroot ./work/x86_64/ < ./airootfs/root/customize_airootfs.sh
#Cleanup
sudo umount /dev/loop0p1
sudo umount /dev/loop0p2
sudo losetup -d /dev/loop0
