#!/bin/bash
#Script for backup VM (checked shutdown, dd from LV to \backup folder, start)  (ver 1.6 for "Machen" centos7 kvm)

#changelog: 
#1.4 - while loop added cheking VM stat every 1 minute until it will be shut
#1.5 - condtion check added: if vm is already shut
#1.6 - code optimized

clear

dt=`date +"%d-%m-%Y(%H:%M)"`

echo "list of VMs:

"

virsh list --all

vg=/dev/vgvm

echo -n "VM name to backup: "
read vm
lv=$vm


vmstate=`virsh dominfo $vm | awk '{ print $2 }' | awk '(NR == 5)'`

statedigits=`echo -n $vmstate | wc -c`


if [[ $statedigits == 7 ]]
then
echo "Shutting down VM... Proccess will be continued in 1 minutes"
virsh shutdown $vm 2>/dev/null
sleep 1m
fi


while [[ $statedigits == 7 ]]
do
echo "VM is still running. Trying to shut it down again. Process wil be continued in 1 minute"
virsh shutdown $vm 2>/dev/null
sleep 1m
vmstate=`virsh dominfo $vm | awk '{ print $2 }' | awk '(NR == 5)'`
statedigits=`echo -n $vmstate | wc -c`
done


pv $vg/$lv | dd of=/backup/"$vm"_"$dt" bs=16M

echo "Backup complete! Starting VM..."

virsh start $vm

