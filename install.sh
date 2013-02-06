#!/bin/sh

TMP=/tmp/.instvar
JOURNAL=/tmp/.instlog

shell(){
	dialog --msgbox "Redirecting you to command shell. Type \"exit\" when you finish." 0 0
	zsh
}

# Welcome!
#echo Welcome to the Energy Linux installer.
#echo Energy Linux is a lightweight Linux distribution based on Arch with batteries and other stuff included. Our goal is to create a distribution simple as Arch but works out of the box. We hope you will like it.
#echo Press Enter to begin installation.
#read
dialog --msgbox "Welcome to the Energy Linux installer.

Energy Linux is a lightweight Linux distribution based on Arch with batteries and other stuff included. Our goal is to create a distribution simple as Arch but works out of the box. We hope you will like it.

Click OK to begin installation." 0 0

# Partition
#echo At first we need to partition the hard drive. If you have no special needs, create one partition filling the whole disk.
#echo Enter your hard drive name or leave blank "for" /dev/sda:
#read disk
#if [ -z $disk ]; then disk="/dev/sda"; fi
#echo == cfdisk $disk
disks1="`lsblk -r | grep disk | cut -d" " -f1`"
disks=""
for i in $disks1; do disks="${disks} /dev/${i} -"; done
dialog --no-cancel --menu "At first we need to partition the hard drive. If you have no special needs, create one partition filling the whole disk.

Select your hard drive or \"manual\" if you want command shell." 0 0 0 $disks manual "" 2> $TMP
disk=`cat $TMP`
case $disk in
	manual)
		shell
		;;
	*)
		cfdisk $disk
		;;
esac

# FS
echo Now we must create filesystems. Enter \"manual\" to manually create them, or enter desired partition to create ext4 on, or leave blank to create ext4 on ${disk}1:
read fs
case $fs in
	manual)
		shell
		;;
	"")
		echo == mkfs.ext4 ${disk}1
		;;
	*)
		echo == mkfs.ext4 $fs
		;;
esac

# Mount
echo Now we need to mount new filesystems to /mnt. Enter \"manual\" to manually mount them, or enter desired partition to mount, or leave blank to mount ${disk}1:
read mou
case $mou in
	manual)
		shell
		;;
	"")
		echo == mount ${disk}1 /mnt
		;;
	*)
		echo == mount $mou /mnt
		;;
esac

# Internet
echo It would be great to connect to the Internet to fetch latest updates. Of course, you can skip this step and install them later. Moreover, if you connect using eth0 \(default wired connection\), connection will be established automatically. In any of these cases, just type \"exit\" to leave command "shell;" else configure your connection manually.
shell
#TODO: wifi-menu

# TODO: Mirrorlist
#echo You may want to edit /etc/pacman.d/mirrorlist
# OR NOT

# Pacstrap it
echo Okay, now we will pacstrap base packages to your new system. Just relax and wait.
echo == pacstrap /mnt base
# TODO: base-devel

# TODO: select bootloader
#GRUB
#    For BIOS: 
# arch-chroot /mnt pacman -S grub-bios
#    For EFI (in rare cases you will need grub-efi-i386 instead): 
# arch-chroot /mnt pacman -S grub-efi-x86_64
#    Install GRUB after chrooting (refer to the #Configure the system section). 
#Syslinux
# arch-chroot /mnt pacman -S syslinux
echo == arch-chroot /mnt pacman -S grub-bios
#echo Now you must install a bootloader. Sorry, this part is not automated yet.
#shell

# fstab
echo Okay. Now we will generate fstab "for" your new system. Just relax and wait.
echo == genfstab -p /mnt >> /mnt/etc/fstab

# TODO: hostname

# TODO: localtime

# TODO: locale

# TODO: console font

# TODO: /etc/locale.gen and generate with locale-gen.

# TODO:      Configure /etc/mkinitcpio.conf as needed (see mkinitcpio) and create an initial RAM disk with: 
# mkinitcpio -p linux

# TODO: Configure the bootloader

# TODO: set root password

# TODO: edit pacman.conf

# TODO: add user

# Complete
echo Installation "complete!" Type \"reboot\" to reboot now.
