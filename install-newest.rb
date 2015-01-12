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
			system 'read'
		end
	else
		print "[DEBUG]=> #{x}"
		system "sleep 2s"
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

# Installer utilities ==========================================================

def hdds
	return `ls /dev/sd?`.split("\n")
end

def mkfses
	return `ls /usr/bin/mkfs.* | sed 's|/usr/bin/mkfs.||g'`.split("\n")
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
- 'Generate locales' \
- 'Set preferred locale' \
- 'Set console keymap and font' \
- 'Configure the network' \
- 'Tune mkinitcpio.conf' \
- 'Set root password' \
- 'Create a user' \
- 'Set up sudo' \
- 'Set up dhcpcd' \
- 'Install yaourt' \
- 'Install Xorg' \
- 'Install TTF fonts' \
- 'Install display drivers' \
- 'Install GNOME' \
- 'Install other packages' \
- 'Install codecs' \
- 'Set up DNS caching' \
- 'Set up mlocate' \
- 'Install CUPS' \
- 'Install zsh' \
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
