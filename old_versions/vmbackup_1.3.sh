#!/bin/bash
#Script for backup VM (checked shutdown, dd from LV to \backup folder, start)  (ver 1.3 for "Machen" centos7 kvm)

clear

dt=`date +"%d-%m-%Y(%H:%M)"`

echo "list of VMs:

"

virsh list --all

vg=/dev/vgvm

echo -n "VM name to backup: "
read vm
lv=$vm

echo "Shutting down VM... Proccess will be continued in 2 minutes"
virsh shutdown $vm
sleep 2m  

vmstate=`virsh dominfo $vm | awk '{ print $2 }' | awk '(NR == 5)'`
run=`echo "running"`

con1=`echo -n $vmstate | wc -c`
con2=`echo -n $run | wc -c`

if [[ $con1 == $con2 ]]; then
echo "VM is still running. Shut it down manually. Backup stopped"
exit 0
fi


pv $vg/$lv | dd of=/backup/"$vm"_"$dt" bs=16M

echo "Backup complete! Starting VM..."

virsh start $vm

