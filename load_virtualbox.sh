#!/bin/bash


#LightDM does not work for some reason
disk_image=./production_disk.img
if [ "$1" != "" ]; then
    echo "Using image $disk_image"
    disk_image=$1
else
    echo "Using default image at $disk_image"
fi

sudo losetup -P /dev/loop0 $disk_image
sudo VBoxManage internalcommands createrawvmdk -filename "./loop.vmdk" -rawdisk /dev/loop0
