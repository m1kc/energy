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

messagebox()
{
	dialog --msgbox "$1" 0 0
}

infobox()
{
	dialog --infobox "$1" 0 0
}

installer_welcome()
{
messagebox "Welcome to the Energy Linux installer.

Energy Linux is a lightweight Linux distribution based on Arch with batteries and other stuff included. Our goal is to create a distribution simple as Arch but works out of the box. We hope you will like it.

Click OK to begin installation."
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
mirrors1=`cat /etc/pacman.d/mirrorlist | grep -v "#" | grep "tp://" | cut -d" " -f3`
mirrors=""
for i in $mirrors1; do mirrors="${mirrors} ${i} -"; done
dialog --menu "Select a mirror to use during install." 0 0 0 $mirrors 2> $TMP
if [ $? "!=" 0 ]; then return; fi
mirror=`cat $TMP`
echo "Server = ${mirror}" "111>111" /etc/pacman.d/mirrorlist
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
infobox "Creating fstab..."
echo == genfstab -U -p /mnt "111>>111" /mnt/etc/fstab

### hostname
dialog --no-cancel --inputbox "Please specify your hostname. It is okay to leave default one." 0 0 "myhost" 2> $TMP
echo == cat $TMP "111>111" /mnt/etc/hostname

### timezone

# TODO: UTC/localtime
#To change the hardware clock time standard to localtime use:
# timedatectl set-local-rtc 1
#And to set it to UTC use:
# timedatectl set-local-rtc 0

#dialog --no-cancel --menu "Select your hardware clock mode. It is recommended to use UTC, but if you have Windows installed, you should you localtime." 0 0 0  0 UTC 1 localtime  2> $TMP
#rtc=`cat $TMP`
#echo == timedatectl --root=/mnt set-local-rtc $rtc

timezones1=`timedatectl --no-pager list-timezones`
timezones=""
for i in $timezones1; do timezones="${timezones} ${i} -"; done
dialog --no-cancel --menu "Select a timezone." 0 0 0 $timezones 2> $TMP
timezone=`cat $TMP`
echo == arch-chroot /mnt ln -s /usr/share/zoneinfo/${timezone} /etc/localtime

### TODO: set up NTP

### TODO: locale: locale.conf
# TODO: /etc/locale.gen and generate with locale-gen.

### TODO: console font

### mkinitcpio
# TODO: Configure /etc/mkinitcpio.conf as needed
infobox "Creating initial RAM disk..."
echo == arch-chroot /mnt mkinitcpio -p linux

### Root password
messagebox "Now we need to set root password."
echo == arch-chroot /mnt passwd

### Create new user
dialog --no-cancel --inputbox "Now we will create new user account. Please specify its name." 0 0 "user" 2> $TMP
username=`cat $TMP`
# TODO: -s /bin/zsh
# TODO: -G networkmanager ?
# TODO: -G camera ? errors
# TODO: -G fuse ?
echo == arch-chroot /mnt useradd -m -g users -G audio,disk,floppy,games,locate,lp,network,optical,power,scanner,storage,sys,video,wheel -s /bin/bash ${username}
echo == arch-chroot /mnt passwd ${username}

### sudo
infobox "Installing sudo..."
echo == arch-chroot /mnt pacman -S --noconfirm sudo

echo == cat /mnt/etc/sudoers | sed "s/# %wheel\tALL=(ALL) ALL/%wheel\tALL=(ALL) ALL/" | sed "s/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/" "111>111" /mnt/etc/sudoers.new
echo == mv /mnt/etc/sudoers.new /mnt/etc/sudoers
# TODO: preprocess | from "111|111"

### dhcpcd
dialog --yesno "Enable dhcpcd?

Answer \"yes\" if you are not sure." 0 0
if [ $? == 0 ]; then
	echo == systemctl --root=/mnt enable dhcpcd.service
fi

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

infobox "Installing grub..."
echo == arch-chroot /mnt pacman -S --noconfirm grub-bios

disks1="`lsblk -r | grep disk | cut -d" " -f1`"
disks=""
for i in $disks1; do disks="${disks} /dev/${i} -"; done
dialog --menu "Select a hard drive for grub to be installed." 0 0 0 $disks 2> $TMP
if [ $? "!=" 0 ]; then return; fi
disk=`cat $TMP`

infobox "Installing grub to MBR..."
echo == arch-chroot /mnt grub-install $disk
infobox "Creating grub.cfg..."
echo == arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

ITEM=9
}

installer_stuff()
{
### X server
dialog --yesno "Install X server?

Answer \"yes\" if you are not sure." 0 0
if [ $? == 0 ]; then
	echo == arch-chroot /mnt pacman -S --noconfirm xorg-server xorg-xinit xf86-video-vesa xterm
fi

### LXDE
dialog --yesno "Install LXDE?

Answer \"yes\" if you are not sure." 0 0
if [ $? == 0 ]; then
	echo == arch-chroot /mnt pacman -S --noconfirm gamin
	messagebox "Pacman will ask you about packages to install - just press Enter to install them all. Then you will be asked about libgl implementation - choose appropriate one for your video card or press Enter to leave default one."
	echo == arch-chroot /mnt pacman -S lxde
	echo == cp /mnt/etc/skel/.xinitrc /mnt/home/${username}/
	echo "" "111>>111" /mnt/home/${username}/.xinitrc
	echo "## Added by Energy Linux installer." "111>>111" /mnt/home/${username}/.xinitrc
	echo "exec startlxde" "111>>111" /mnt/home/${username}/.xinitrc
	# TODO: exec ck-launch-session dbus-launch startlxde ?
fi

### Fonts
dialog --yesno "Install TTF fonts?

Answer \"yes\" if you are not sure." 0 0
if [ $? == 0 ]; then
	echo == arch-chroot /mnt pacman -S --noconfirm ttf-bitstream-vera ttf-dejavu ttf-droid ttf-freefont ttf-liberation ttf-ubuntu-font-family
fi

ITEM=reboot
}

installer_main()
{
dialog --nocancel --default-item $ITEM --menu "Do it step-by-step." 0 0 0 1 "Partition hard drive" 2 "Create filesystem" 3 "Mount filesystem" 4 "Connect to Internet" 5 "Select a mirror" 6 "Pacstrap" 7 "Configure new system" 8 "Install bootloader" 9 "Install optional packages" reboot Reboot zsh "Wait! I need command shell." abort Abort 2> $TMP
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
