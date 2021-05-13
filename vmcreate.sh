#!/bin/bash
# script for create VM on Centos 7 KVM for "Machen"  (ver 1.3)
# 1.3 - Mac address is shown after VM creation
# 1.4 - virio-win.iso added as a second cd-rom drive (hdb)



clear

echo -n "Select VM mode:

1. New VM
2. Define from xml
: "
read loc
case $loc in

#NEW
1)

#change volume group to actual one if it does not coincide with the hostname

vg=/dev/vgvm
 
 
echo -n "VM name: "
read vm
echo -n "HDD size in GB: "
read size
echo -n "Memory in GB: "
read memory
echo -n "CPU count: "
read cpu

echo -n "Select OS
1. Linux
2. Windows
: "
read os


#noimage=$[`ls  /images | wc -l`+1]
echo "Avaliable OS template images:"
ls /images | cat -b
echo ""
echo -n "Select OS template image number from the list (press "0" if no image needed): "
read inumber
image=`ls /images | sed -n $inumber"p" 2>/dev/null`


echo "Avaliable distributive CD-ROM images:"
ls /distribs | cat -b
echo ""
echo -n "Select distributive image number from the list to mount as a CD-ROM (press "0" if no image needed): "
read dnumber
cdimage=/distribs/`ls /distribs | sed -n $dnumber"p" 2>/dev/null`
if [ "$dnumber" == 0 ] || [ -z "$dnumber" ]; then
cdimage=/dev/null
fi



echo "Avaliable bridges:" 
brctl show | grep kvm | awk '{print $1}' | cat -b
echo ""
echo -n "Select bridge number from the list: "
read bnumber
bridge=`brctl show | grep kvm  | awk '{print $1}' | sed -n $bnumber"p"`

lvcreate -n$vm -L$size"G" $vg

echo "Importing image, please wait...."

pv /images/$image | dd of=$vg/$vm bs=16M

#dd if=/images/$image of=$vg/$vm bs=16M

case $os in
1)

(echo d; echo n; echo p; echo 1; echo "2048"; echo $'\n'; echo w) | fdisk $vg/$vm

partprobe
;;
2)
;;
esac

echo "
<domain type='kvm'>
  <name>$vm</name>
  <memory unit='G'>$memory</memory>
  <currentMemory unit='G'>$memory</currentMemory>
  <vcpu>$cpu</vcpu>
  <os>
    <type arch='x86_64' machine='pc'>hvm</type>
    <boot dev='cdrom'/>
    <boot dev='hd'/>
    <bootmenu enable='yes'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/libexec/qemu-kvm</emulator>
    <disk type='block' device='disk'>
      <driver name='qemu' type='raw'/>
      <source dev='$vg/$vm'/>
      <target dev='vda' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </disk>
    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <target dev='hda' bus='ide'/>
      <source file='$cdimage'/>
      <readonly/>
      <address type='drive' controller='0' bus='1' target='0' unit='0'/>
    </disk>
      <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/usr/share/virtio-win/virtio-win-0.1.171.iso'/>
      <target dev='hdb' bus='ide'/>
      <readonly/>
      <address type='drive' controller='0' bus='1' target='0' unit='1'/>
    </disk>
    <controller type='ide' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
    </controller>
    <interface type='bridge'>
      <source bridge='$bridge'/>
      <target dev='${vm:0:15}'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <input type='mouse' bus='ps2'/>
    <graphics type='vnc' port='-1' autoport='yes' keymap='en-us' listen='0.0.0.0'/>
    <video>
      <model type='cirrus' vram='9216' heads='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </memballoon>
  </devices>
</domain>

" > $vm.xml

virsh define $vm.xml
virsh autostart $vm
virsh start $vm
rm $vm.xml

echo "VM created"
virsh dumpxml $vm | grep "mac address"
;;
2)
echo -n "Path to xml: "
read path
cd $path
echo -n "VM name: "
read vm
virsh pool-define pool-$vm.xml
virsh pool-start pool-$vm
virsh pool-autostart pool-$vm
virsh define $vm.xml
virsh start $vm
virsh autostart $vm             
;;
esac 
