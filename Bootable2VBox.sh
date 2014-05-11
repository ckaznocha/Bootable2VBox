#!/bin/bash
#
# Bootable2VBox.sh
# A Shell script to create a new VirtualBox VM from a bootable drive.
#
# Written by Clifton Kaznocha
# Copyright (c) 2014 Clifton Kaznocha
#
# License: MIT
#

# Warn the user that this script could be dangerous and give them a chance to exit
echo "WARNING: This script is potentially dangerous. It could cause damage to your data. Use at your own risk"
while true; do
	read -p "Are you sure you want to run continue? (y/n)" yn
	case $yn in
		[Yy]* ) break;;
		[Nn]* ) exit;;
		* ) echo "Please answer y or n.";;
	esac
done

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Get the users name
the_user=${SUDO_USER:-${USERNAME:-unknown}}

# The name that will be used for the VM. You may wish to change this.
vm_name="BootableOS"

# Some settings for the VM and their corresponding values. These are just what works for me.
# If you make any changes here be sure that the arrays line up!
vm_settings=(ioapic rtcuseutc mouse vram accelerate3d memory nic1 audio audiocontroller ostype)
vm_settings_values=("on" "on" "usbmultitouch" "64" "on" "1024" "nat" "coreaudio" "ac97" "Ubuntu_64")

# Make sure VBoxManage is installed
if hash VBoxManage 2>/dev/null; then

	# List the available drives
	# Use diskutil if its available
	if hash diskutil 2>/dev/null; then
		sudo -u "${the_user}" diskutil list
	else
		fdisk -l
	fi

	# Prompt the user to choose the correct disk
	read -p "Which Disk has your bootable OS on it? (E.g. if the disk is '/dev/disk1' enter 'disk1')" driveNumber
	
	# Double check that hey picked the correct one
	while true; do
		read -p "You are about to unmount /dev/${driveNumber}. Are you absolutely sure? (y/n)" yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) exit;;
			* ) echo "Please answer yes or no.";;
		esac
	done

	# if the disk is mounted we will need to unmount it.
	# Use diskutil if its available
	if hash diskutil 2>/dev/null; then
		mount | grep -q -m1 -B0 -A0 -w ^"/dev/${driveNumber}" && sudo -u "${the_user}" diskutil unmount "/dev/${driveNumber}"
	else
		mount | grep -q -m1 -B0 -A0 -w ^"/dev/${driveNumber}" && sudo -u "${the_user}" unmount "/dev/${driveNumber}"
	fi
	
	# VirtualBox needs the disk to be owned by the current user.
	# Make sure it really exists before chowning it.
	if [ -e "/dev/${driveNumber}" ]; then
		chown "${the_user}" "/dev/${driveNumber}"
	else 
		echo "/dev/${driveNumber} was not found"
		exit
	fi

	# If there is already a VM with the same name we need to remove it and recreate it.
	sudo -u "${the_user}" VBoxManage showvminfo ${vm_name} | grep -w ^"Name:.*${vm_name}" && sudo -u "${the_user}" VBoxManage unregistervm ${vm_name} --delete
	# Create the new raw disk
	sudo -u "${the_user}" VBoxManage internalcommands createrawvmdk -filename ${vm_name}.vmdk -rawdisk "/dev/${driveNumber}"
	# Create the new VM
	sudo -u "${the_user}" VBoxManage createvm --name "${vm_name}" --register

	# Loop through the settings array and apply each one
	i=0
	let num_settings=${#vm_settings[@]}-1
	while [ $i -le ${num_settings} ]
	do
		read -p "Value for VM setting '${vm_settings[i]}'?(Press return for default '${vm_settings_values[i]}''):" user_value
		if [[ ! -z $user_value ]]; then
			vm_settings_values[i]=${user_value}
		fi
		sudo -u "${the_user}" VBoxManage modifyvm "${vm_name}" --${vm_settings[i]} "${vm_settings_values[i]}"
		((i++))
	done

	# Create an IDE Controller
	sudo -u "${the_user}" VBoxManage storagectl "${vm_name}" --name "IDE Controller" --add ide
	# Attach the raw disk to the IDE Controller
	sudo -u "${the_user}" VBoxManage storageattach "${vm_name}" --storagectl "IDE Controller"  --port 0 --device 0 --type hdd --medium ./${vm_name}.vmdk

	# Ask the user if they would like to start the VM now.
	while true; do
		read -p "Start VM now? (y/n)" yn
		case $yn in
			[Yy]* ) sudo -u "${the_user}" VBoxManage startvm ${vm_name}; break;;
			[Nn]* ) exit;;
			* ) echo "Please answer yes or no.";;
		esac
	done
else
	echo "VBoxManage not found. Exiting."
fi

exit
