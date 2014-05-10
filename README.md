Bootable2VBox
================================

This is a small shell script to crate a New VirtualBox VM and Raw Disk from a external drive with a bootable OS on it. Because the external drive's UUID changes you need to recreate the VM every time you plug it in. This script makes that process simpler.

## WARNINGS
I am in no way affiliated with VirtualBox. I just wanted to eliminate something that was annoying to me.

### Data loss
Running this script could cause damage to your data or your drives. Use it at your one risk. I take no responsibility and cannot help you if something goes wrong.

### Supported OS
I have only used this script on OS X 10.8.5. It may work on other versions of OS X and Linux, it has not been tested. I make no guarantees.

I use this to launch a VirtualBox VM from a bootable USB thumb drive with Ubuntu 14.04 installed on it. It may work for other operating systems on different types of bootable media.

### Settings
The list of settings applied by this script and their defaults are just what work for me. They may not work for you, you might want to change them.

Refer to the Virtualbox manual for information: http://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm

## Installation
Just download the script. You'll need to update the permissions to make it executable. If you don't know how to make it executable you probably shouldn't use it.

## Usage
Execute the script from the terminal. You must use `sudo` to run it as root. If you are unfamiliar with `sudo` then you probably shouldn't use this script.

On OS X you might get some notifications about your drive not being readable. Just click ignore. What ever you do **DO NOT** initialize the disk.

**Note:** Avoid installing VirtualBox Guest Additions on your bootable OS is you wish to still be able to boot directly from it on a physical computer.