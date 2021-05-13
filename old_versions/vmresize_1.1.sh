#!/bin/bash
#Script for resize VM (checked shutdown, lvresize, fdisk, VM start)  (ver 1.1 for "Machen" centos7 kvm)

#changelog: 


clear


echo "list of VMs:

"

virsh list --all

vg=/dev/vgvm

echo -n "VM name to resize: "
read vm
echo -n "Size to increase in GB: "
read size

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


lvresize -L+"$size"G $vg/$vm

(echo d; echo n; echo p; echo 1; echo "2048"; echo $'\n'; echo w) | fdisk $vg/$vm

partprobe



echo "Resize complete! Starting VM..."

virsh start $vm

