#!/bin/sh

# echo ==
# will be eliminated
#
# "111>>111"
# will be replaced to
# >>
#
# "111>111"
# will be replaced to
# >

TMP=/tmp/.instvar
JOURNAL=/tmp/.instlog
ITEM=1

installer_welcome()
{
dialog --msgbox "Welcome to the Energy Linux installer.

Energy Linux is a lightweight Linux distribution based on Arch with batteries and other stuff included. Our goal is to create a distribution simple as Arch but works out of the box. We hope you will like it.

Click OK to begin installation." 0 0
}

installer_partition()
{
disks1="`lsblk -r | grep disk | cut -d" " -f1`"
disks=""
for i in $disks1; do disks="${disks} /dev/${i} -"; done
# TODO: text
# At first we need to partition the hard drive. If you have no special needs, create one partition filling the whole disk.
dialog --menu "Select a hard drive to partition." 0 0 0 $disks 2> $TMP
if [ $? "!=" 0 ]; then return; fi
disk=`cat $TMP`
echo == cfdisk $disk
ITEM=2
}

installer_makefs()
{
partitions1="`lsblk -r | grep part | cut -d" " -f1`"
partitions=""
for i in $partitions1; do partitions="${partitions} /dev/${i} -"; done
# TODO: text
# Now we must create filesystems.
dialog --menu "Select a partition to create ext4 on." 0 0 0 $partitions 2> $TMP
if [ $? "!=" 0 ]; then return; fi
partition=`cat $TMP`
echo == mkfs.ext4 $partition
ITEM=3
}

installer_mount()
{
partitions1="`lsblk -r | grep part | cut -d" " -f1`"
partitions=""
for i in $partitions1; do partitions="${partitions} /dev/${i} -"; done
# TODO: text
# Now we need to mount new filesystems to /mnt.
dialog --menu "Select a partition to be mounted to /mnt." 0 0 0 $partitions 2> $TMP
if [ $? "!=" 0 ]; then return; fi
mou=`cat $TMP`
echo == mount $mou /mnt
ITEM=4
}

installer_internet()
{
# TODO: text
# TODO: maybe, PPPoE?
dialog --menu "It would be great to connect to the Internet to fetch latest updates. Of course, you can skip this step and install them later. Moreover, if you connect using wired connection like eth0, connection will be established automatically. In any of these cases, just type \"exit\" to leave command shell; otherwise configure your connection manually." 0 0 0 check "Check connection" wifi "Select wireless network" 2> $TMP
internet=`cat $TMP`
case $internet in
	check)
		echo == ping -c 5 google.com
		;;
	wifi)
		echo == wifi-menu
		;;
esac
ITEM=5
}

installer_mirrors()
{
# TODO: ADD SOME TEXT!
echo == nano /etc/pacman.d/mirrorlist
# TODO: copy it?
ITEM=6
}

installer_pacstrap()
{
#dialog --msgbox "Okay, now we will pacstrap base packages to your new system. Just relax and wait." 0 0
echo == pacstrap /mnt base
# TODO: base-devel w/ text
ITEM=7
}

installer_conf()
{
### fstab
dialog --infobox "Creating fstab..." 0 0
echo == genfstab -U -p /mnt "111>>111" /mnt/etc/fstab

### hostname
dialog --inputbox "Please specify your hostname. It is okay to leave default one." 0 0 "myhost" 2> $TMP
echo == cat $TMP "111>111" /mnt/etc/hostname

### timezone
# TODO: FUCK IT, USE SYSTEMD
#To change the hardware clock time standard to localtime use:
# timedatectl set-local-rtc 1
#And to set it to UTC use:
# timedatectl set-local-rtc 0
#
#To check the current zone:
#$ timedatectl status
#To list available zones:
#$ timedatectl list-timezones
#To change your time zone:
# timedatectl set-timezone <Zone>/<SubZone>
#Example:
# timedatectl set-timezone Canada/Eastern

### TODO: set up NTP

### TODO: locale: locale.conf
# TODO: /etc/locale.gen and generate with locale-gen.

### TODO: console font

### mkinitcpio
# TODO: Configure /etc/mkinitcpio.conf as needed
dialog --infobox "Creating initial RAM disk..." 0 0
echo == arch-chroot /mnt mkinitcpio -p linux

### Root password
dialog --msgbox "Now we need to set root password." 0 0
echo == arch-chroot /mnt passwd

ITEM=8
}

installer_bootload()
{
# TODO: select
#dialog --msgbox "Sorry!" 0 0

#GRUB
#    For BIOS: 
# arch-chroot /mnt pacman -S grub-bios
#    For EFI (in rare cases you will need grub-efi-i386 instead): 
# arch-chroot /mnt pacman -S grub-efi-x86_64
#    Install GRUB after chrooting (refer to the #Configure the system section). 
#Syslinux
# arch-chroot /mnt pacman -S syslinux

dialog --infobox "Installing grub..." 0 0
echo == arch-chroot /mnt pacman -S --noconfirm grub-bios

disks1="`lsblk -r | grep disk | cut -d" " -f1`"
disks=""
for i in $disks1; do disks="${disks} /dev/${i} -"; done
dialog --menu "Select a hard drive for grub to bee installed." 0 0 0 $disks 2> $TMP
if [ $? "!=" 0 ]; then return; fi
disk=`cat $TMP`

dialog --infobox "Installing grub to MBR..." 0 0
echo == arch-chroot /mnt grub-install $disk
dialog --infobox "Creating grub.cfg..." 0 0
echo == arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

ITEM=9
}

installer_stuff()
{
# TODO: make install clean
dialog --msgbox "Sorry!" 0 0
ITEM=reboot
}

installer_main()
{
dialog --nocancel --default-item $ITEM --menu "Do it step-by-step." 0 0 0 1 "Partition hard drive" 2 "Create filesystem" 3 "Mount filesystem" 4 "Connect to Internet" 5 "Select mirrors" 6 "Pacstrap" 7 "Configure new system" 8 "Install bootloader" 9 "Install optional packages" reboot Reboot zsh "Wait! I need command shell." abort Abort 2> $TMP
variant=`cat $TMP`
case $variant in
	1)
		installer_partition
		;;
	2)
		installer_makefs
		;;
	3)
		installer_mount
		;;
	4)
		installer_internet
		;;
	5)
		installer_mirrors
		;;
	6)
		installer_pacstrap
		;;
	7)
		installer_conf
		;;
	8)
		installer_bootload
		;;
	9)
		installer_stuff
		;;
	reboot)
		dialog --yesno "Reboot now?" 0 0
		if [ $? == 0 ]; then
			echo == reboot
			exit
		fi
		;;
	zsh)
		echo Type \"exit\" or press "Ctrl+D" when you finish.
		zsh
		;;
	abort)
		exit
		;;
esac
installer_main
}

installer_welcome
installer_main
