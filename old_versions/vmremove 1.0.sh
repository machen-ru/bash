#!/bin/bash
#Script for remove VM, LV  (ver 1.0 for "Machen" centos7 kvm)

vg=/dev/vgvm

echo -n "VM name: "
read vm
lv=$vm

virsh destroy $vm
virsh undefine $vm
 

map_num1=`dmsetup info -c | grep $lv | awk  '{print $3}'`
dmsetup remove -f /dev/dm-$map_num1 

lvremove -f `lvdisplay -c | awk -F: '{print $1}' | grep -w $lv`

