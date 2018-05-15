class Installer(object):
	def __init__(self, conf, pc):
		super(Installer, self).__init__()
		self.conf = conf
		self.pc = pc

	def execute(self):
		bm = self.pc.boot_mode()
		print(f"Detected boot mode is: {bm}")
		if bm != 'bios':
			print(f'We support only BIOS. Stopping.')
			return

		if self.conf['storage_auto'] == True:
			self.pc.create_pt('sda', 'mbr')
			self.pc.create_partition('sda', 'sda1')
			self.pc.mkfs('sda1', 'ext4')
			self.pc.mount('sda1', '/mnt')
		else:
			print('`storage_auto` is not set, skipping partitioning')
			print('Assuming filesystems are mounted on /mnt')

		self.pc.pacstrap('/mnt', ['base'])
		self.pc.genfstab('/mnt', ['-U'], '/mnt/etc/fstab')

		if self.conf['bootloader'] == 'grub':
			self.pc.chroot_install(['grub'])
			self.pc.chroot_configure_loader('grub')
			self.pc.chroot_install_loader('grub', 'sda')
		else:
			print(f"Unknown bootloader `{self.conf['bootloader']}`, skipping")

		self.pc.chroot_passwd('root', self.conf.root_passwd)
