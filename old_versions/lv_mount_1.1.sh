#!/bin/bash
#Script for create new lv ext4 partition mounted to a new directory   (ver 1.0 for "Machen" centos7 kvm)

clear
echo -n "Mount point name: "
read lv
echo -n "Partition size: "
read size
lvcreate -n$lv -L$size"G" vgvm 
mkdir /$lv
mkfs.ext4 /dev/vgvm/$lv
resize2fs /dev/vgvm/$lv
echo "/dev/vgvm/$lv         /$lv                 ext4    defaults        0 0" >> /etc/fstab
mount -a

