#!/bin/sh

# echo ==
# will be eliminated
#
# ;  sleep 1s
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
ITEM=11


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

Hit OK to begin installation."
}

installer_main()
{
dialog --nocancel --default-item $ITEM --menu "Do it step-by-step." 0 0 0 11 "cfdisk" 12 "mkfs.ext4" 13 "mount" 21 "wifi-menu" 22 "ping" 23 "nano /etc/pacman.d/mirrorlist" 31 "pacstrap /mnt base" 32 "pacstrap /mnt base base-devel" 33 'genfstab -p /mnt >> /mnt/etc/fstab' 34 'arch-chroot /mnt hostnamectl set-hostname' 35 'arch-chroot /mnt ln -s /usr/share/zoneinfo/<Zone>/<SubZone> /etc/localtime' 36 'nano /mnt/etc/locale.gen' 37 'arch-chroot /mnt locale-gen' 38 'nano /mnt/etc/locale.conf' 39 'nano /mnt/etc/vconsole.conf' 3A 'arch-chroot /mnt mkinitcpio -p linux' 3B 'arch-chroot /mnt passwd' 3C 'nano /mnt/etc/pacman.d/mirrorlist' reboot "Reboot" zsh "Wait! I need command shell." quit "Quit" 2> $TMP
variant=`cat $TMP`
case $variant in
	11)
		# TODO: /dev/sdX menu
		dialog --inputbox "Specify device:" 0 0 "/dev/sd" 2> $TMP
		if [ $? == 0 ]; then
			variant=`cat $TMP`
			echo == cfdisk "$variant";  sleep 1s
		fi
		ITEM=12
		;;
	12)
		# TODO: /dev/sdXY menu
		dialog --inputbox "Specify partition:" 0 0 "/dev/sd" 2> $TMP
		if [ $? == 0 ]; then
			variant=`cat $TMP`
			echo == mkfs.ext4 "$variant";  sleep 1s
		fi
		ITEM=13
		;;
	13)
		# TODO: /dev/sdXY menu
		dialog --inputbox "Specify partition:" 0 0 "/dev/sd" 2> $TMP
		if [ $? == 0 ]; then
			partition=`cat $TMP`
			dialog --inputbox "Specify mountpoint:" 0 0 "/mnt" 2> $TMP
			if [ $? == 0 ]; then
				mountpoint=`cat $TMP`
				echo == mount "$partition" "$mountpoint";  sleep 1s
			fi
		fi
		ITEM=21
		;;
	21)
		echo == wifi-menu;  sleep 1s
		ITEM=22
		;;
	22)
		ping -c 3 8.8.8.8
		ITEM=23
		;;
	23)
		echo == nano /etc/pacman.d/mirrorlist;  sleep 1s
		ITEM=31
		;;
	31)
		echo == pacstrap /mnt base;  sleep 1s
		ITEM=32
		;;
	32)
		echo == pacstrap /mnt base base-devel;  sleep 1s
		ITEM=33
		;;
	33)
		echo == genfstab -p /mnt "111>>111" /mnt/etc/fstab;  sleep 1s
		ITEM=34
		;;
	34)
		# TODO: ask hostname
		# arch-chroot /mnt hostnamectl set-hostname
		messagebox "Not implemented. Sorry."
		ITEM=35
		;;
	35)
		# TODO: ask timezone & subzone
		# arch-chroot /mnt ln -s /usr/share/zoneinfo/<Zone>/<SubZone> /etc/localtime
		messagebox "Not implemented. Sorry."
		ITEM=36
		;;
	36)
		echo == nano /mnt/etc/locale.gen;  sleep 1s
		ITEM=37
		;;
	37)
		echo == arch-chroot /mnt locale-gen;  sleep 1s
		ITEM=38
		;;
	38)
		echo == nano /mnt/etc/locale.conf;  sleep 1s
		ITEM=39
		;;
	39)
		echo == nano /mnt/etc/vconsole.conf;  sleep 1s
		ITEM=3A
		;;
	3A)
		echo == arch-chroot /mnt mkinitcpio -p linux;  sleep 1s
		ITEM=3B
		;;
	3B)
		echo == arch-chroot /mnt passwd;  sleep 1s
		ITEM=3C
		;;
	3C)
		echo == nano /mnt/etc/pacman.d/mirrorlist;  sleep 1s
		ITEM=41
		;;
	reboot)
		dialog --yesno "Reboot now?" 0 0
		if [ $? == 0 ]; then
			echo == reboot;  sleep 1s
			exit
		fi
		;;
	zsh)
		echo Type \"exit\" or press "Ctrl+D" when you finish.
		zsh
		;;
	quit)
		exit
		;;
esac
installer_main
}

installer_welcome
installer_main
