#!/bin/sh

# echo ==
# 	will be eliminated
#
# "111>>111"
# 	will be replaced to
# >>
#
# "111>111"
# 	will be replaced to
# >

TMP=/tmp/.instvar
JOURNAL=/tmp/.instlog

shell(){
	dialog --msgbox "Redirecting you to command shell. Type \"exit\" when you finish." 0 0
	echo == zsh
}

### Welcome!
dialog --msgbox "Welcome to the Energy Linux installer.

Energy Linux is a lightweight Linux distribution based on Arch with batteries and other stuff included. Our goal is to create a distribution simple as Arch but works out of the box. We hope you will like it.

Click OK to begin installation." 0 0

# Partition
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
		echo == cfdisk $disk
		;;
esac

### Filesystem
partitions1="`lsblk -r | grep part | cut -d" " -f1`"
partitions=""
for i in $partitions1; do partitions="${partitions} /dev/${i} -"; done
dialog --no-cancel --menu "Now we must create filesystems.

Select a partition to create ext4 on or \"manual\" if you want command shell." 0 0 0 $partitions manual "" 2> $TMP
partition=`cat $TMP`
case $partition in
	manual)
		shell
		;;
	*)
		echo == mkfs.ext4 $partition
		;;
esac

### Mount
dialog --no-cancel --menu "Now we need to mount new filesystems to /mnt.

Select a partition to mount or \"manual\" if you want command shell." 0 0 0 $partitions manual "" 2> $TMP
mou=`cat $TMP`
case $mou in
	manual)
		shell
		;;
	*)
		echo == mount $partition /mnt
		;;
esac

### Internet
dialog --no-cancel --menu "It would be great to connect to the Internet to fetch latest updates. Of course, you can skip this step and install them later. Moreover, if you connect using wired connection like eth0, connection will be established automatically. In any of these cases, just type \"exit\" to leave command shell; otherwise configure your connection manually." 0 0 0 skip "Skip this step" wired "Just check it" wifi "Select wireless network" manual "" 2> $TMP
internet=`cat $TMP`
case $internet in
	manual)
		shell
		;;
	wired)
		echo == ping -c 5 google.com
		;;
	wifi)
		echo == wifi-menu
		;;
	skip)
		;;
	*)
		;;
esac

# TODO: Mirrorlist
#echo You may want to edit /etc/pacman.d/mirrorlist
# OR NOT

### Pacstrap it
dialog --msgbox "Okay, now we will pacstrap base packages to your new system. Just relax and wait." 0 0
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

### fstab
dialog --msgbox "Okay. Now we will generate fstab for your new system. Just relax and wait." 0 0
echo == genfstab -U -p /mnt "111>>111" /mnt/etc/fstab

### hostname
dialog --inputbox "Please specify your hostname. It is okay to leave default one." 0 0 "myhost" 2> $TMP
echo == cat $TMP "111>111" /mnt/etc/hostname

# TODO: select localtime
dialog --msgbox "Auto-selecting timezone Europe/Moscow. Hope it is OK." 0 0
echo == ln -s /mnt/usr/share/zoneinfo/Europe/Moscow /mnt/etc/localtime
# TODO: FUCK IT

# TODO: locale.conf
# TODO: /etc/locale.gen and generate with locale-gen.

# TODO: console font

### mkinitcpio
# TODO: Configure /etc/mkinitcpio.conf as needed
dialog --msgbox "Now we will create an initial RAM disk. Just relax and wait." 0 0
echo == arch-chroot /mnt mkinitcpio -p linux

# TODO: Configure the bootloader

### Root password
dialog --msgbox "Now we need to set root password." 0 0
echo == arch-chroot /mnt passwd

# TODO: edit pacman.conf

# TODO: add user

### Done!
dialog --yesno "Installation complete! Reboot now?" 0 0
if [ $? == 0 ]; then
	echo == reboot
fi
