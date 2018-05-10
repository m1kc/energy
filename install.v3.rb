#!/usr/bin/env ruby

# Basic stuff ==================================================================

def println(x)
	print "#{x}\n"
end

def invoke(x)
	release = false
	if release
		code = system(x)
		if code == false
			println 'Command failed. Press Enter to continue.'
			system 'sh -c read'
		end
	else
		print "[DEBUG]=> #{x}"
		system "sleep 0.5s"
		print '.'
		system "sleep 0.5s"
		print '.'
		system "sleep 0.5s"
		print '.'
		system "sleep 0.5s"
		print "\n"
	end
end

# Dialogs ======================================================================

def enquote(x)
	while not x['"'].nil?
		x['"'] = 'XXX===XXX'
	end
	while not x['XXX===XXX'].nil?
		x['XXX===XXX'] = '\"'
	end
	return "\"#{x}\""
end

def messagebox(x)
	x = enquote(x)
	system "dialog --msgbox #{x} 0 0"
end

def infobox(x)
	x = enquote(x)
	system "dialog --infobox #{x} 0 0"
end

def ask(x)
	x = enquote(x)
	code = system "dialog --yesno #{x} 0 0"
	return (code)
end

def input(label, default)
	label = enquote(label)
	default = enquote(default)
	# TODO: cancel
	result = `dialog --stdout --no-cancel --inputbox #{label} 0 0 #{default}`
	return result
end

def simplechoose(header, items)
	header = enquote header
	x = ''
	items.each { |item|
		x += "  #{item} -  "
	}
	result = `dialog --stdout --no-cancel --menu #{header} 0 0 0 #{x}`
	return result
end

# Installer utilities ==========================================================

def hdds
	return `ls /dev/sd?`.split("\n")
end

def mkfses
	return `ls /usr/bin/mkfs.* | sed 's|/usr/bin/mkfs.||g'`.split("\n")
end

def locales(from)
	return `cat #{from} | grep -v '^#' | cut -d' ' -f1`.split("\n")
end

# main =========================================================================

n = '1'
while true do
	variant = `dialog --stdout --no-cancel --default-item #{n} --menu 'Energy Linux' 0 0 0 \
10 'Prepare partitions' \
11 'Create filesystems' \
12 'Mount filesystems' \
13 'Create swap partitions' \
14 'Activate swap partitions' \
15 'Check Internet connection' \
16 'Connect to Wi-Fi' \
17 'Choose mirrors' \
18 'Install base packages' \
19 'Create fstab' \
20 'Set hostname' \
- 'Set timezone' \
- 'Set hardware clock mode' \
- 'Activate NTP daemon' \
24 'Generate locales' \
25 'Set preferred locale' \
- 'Set console keymap and font' \
- 'Configure the network' \
- 'Tune mkinitcpio.conf' \
29 'Set root password' \
- 'Set up sudo' \
31 'Create a user' \
- 'Set up dhcpcd' \
- 'Install yaourt' \
- 'Install Xorg' \
- 'Install display drivers' \
- 'Install TTF fonts' \
- 'Install GNOME' \
- 'Install other packages' \
- 'Install codecs' \
- 'Set up DNS caching' \
- 'Set up mlocate' \
- 'Install CUPS' \
43 'Install GRUB' \
reboot 'Reboot' \
zsh 'Wait! I need command shell.' \
quit 'Quit' \
`
	if variant != 'zsh'
		n = variant
	end

	if variant == '10'  # Prepare partitions
		d = input 'Device:', '/dev/sd'
		d = enquote(d)
		invoke "cfdisk #{d}"
	end
	if variant == '11'  # Create filesystems
		d = input 'Device:', '/dev/sd'
		d = enquote(d)
		x = input 'Filesystem:', 'ext4'
		invoke "mkfs.#{x} #{d}"
	end
	if variant == '12'  # Mount filesystems
		d = input 'Device:', '/dev/sd'
		d = enquote(d)
		m = input 'Mountpoint:', '/mnt'
		m = enquote(m)
		invoke "mount #{d} #{m}"
	end
	if variant == '13'  # Create swap partitions
		d = input 'Device:', '/dev/sd'
		d = enquote(d)
		invoke "mkswap #{d}"
	end
	if variant == '14'  # Activate swap partitions
		d = input 'Device:', '/dev/sd'
		d = enquote(d)
		invoke "swapon #{d}"
	end
	if variant == '15'  # Check Internet connection
		code = system 'ping -c1 8.8.8.8'
		messagebox (code ? 'Working fine!' : 'It does not work.')
	end
	if variant == '16'  # Connect to Wi-Fi
		invoke 'wifi-menu'
	end
	if variant == '17'  # Choose mirrors
		invoke 'nano /etc/pacman.d/mirrorlist'
	end
	if variant == '18'  # Install base packages
		devel = ask "Install base-devel packages?\n\nIf you're not sure, say \"yes\".\n\nAlso note that you won't be able to install yaourt without these packages."
		invoke "pacstrap /mnt base #{devel ? 'base-devel':''}"
	end
	if variant == '19'  # Create fstab
		invoke 'genfstab -p /mnt > /mnt/etc/fstab'
	end
	if variant == '20'  # Set hostname
		hostname = input 'Desired hostname:', 'myhost'
		hostname = enquote hostname
		invoke "echo #{hostname} > /mnt/etc/hostname"
	end
	if variant == '24'  # Generate locales
		messagebox 'Now you will see the list of locales. Uncomment the ones you need.'
		invoke 'nano /mnt/etc/locale.gen'
		infobox 'Generating...'
		invoke 'arch-chroot /mnt locale-gen'
	end
	if variant == '25'  # Set preferred locale
		# /mnt/etc/locale.conf
		# example:
		# LANG=ru_RU.UTF-8
		l = simplechoose 'Available locales:', locales('/mnt/etc/locale.gen')
		l = enquote l
		invoke "echo LANG=#{l} > /mnt/etc/locale.conf"
	end
	if variant == '29'  # Set root password
		invoke 'arch-chroot /mnt passwd'
	end
	if variant == '32'  # Create a user
		username = input 'Username:', 'm1kc'
		username = enquote username
		# TODO: zsh
		shell = input 'Shell:', '/bin/bash'
		shell = enquote shell
		groups = input 'Groups:', 'audio,disk,floppy,games,locate,lp,network,optical,power,scanner,storage,sys,video,wheel'
		groups = enquote groups
		invoke "arch-chroot /mnt useradd -m -g users -G #{groups} -s #{shell} #{username}"
		invoke "arch-chroot /mnt passwd #{username}"
	end
	if variant == '43'  # Install GRUB
		d = input 'Device:', '/dev/sd'
		d = enquote(d)
		infobox 'Installing...'
		invoke 'arch-chroot /mnt pacman -S --noconfirm grub-bios'
		invoke "arch-chroot /mnt grub-install #{d}"
		invoke 'arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg'
	end

	if variant == '-'  # Not implemented
		messagebox "Sorry, it is not yet implemented.\n\nCheck the Arch Wiki for instructions."
	end
	if variant == 'reboot'  # Reboot
		infobox 'Rebooting...'
		invoke 'reboot'
		break
	end
	if variant == 'zsh'  # Wait! I need command shell.
		println 'Type "exit" or press Ctrl+D when you are done.'
		invoke 'zsh'
	end
	if variant == 'quit'  # Quit
		break
	end
end
