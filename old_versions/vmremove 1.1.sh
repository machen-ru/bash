#!/bin/bash
#Script for remove VM, LV  (ver 1.1 for "Machen" centos7 kvm)
# 1.1 list of current VMs added

clear

echo "list of VMs:

"

virsh list --all


vg=/dev/vgvm

echo -n "VM name to remove: "
read vm
lv=$vm

virsh destroy $vm
virsh undefine $vm
 

map_num1=`dmsetup info -c | grep $lv | awk  '{print $3}'`
dmsetup remove -f /dev/mapper/$map_num1 

lvremove -f `lvdisplay -c | awk -F: '{print $1}' | grep -w $lv`

