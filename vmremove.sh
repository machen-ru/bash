#!/bin/bash
#Script for remove VM, LV  (ver 1.1 for "Machen" centos7 kvm)
# 1.1 list of current VMs added
# 1.2 dmsetup remove extra options added

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
dmsetup remove -f /dev/dm-$map_num1 2>/dev/null

#map_num2=`ls -la /sys/dev/block/253\:"$map_num1"/holders` 2>/dev/null

dmsetup remove -f /dev/mapper/vgvm-"$vm"p1 2>/dev/null

lvremove -f `lvdisplay -c | awk -F: '{print $1}' | grep -w $lv`

