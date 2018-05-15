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

		device = self.conf['storage_auto_device']
		part = f"{device}1"

		if self.conf['storage_auto'] == True:
			self.pc.create_pt(device, 'mbr')
			self.pc.create_partition(device, part)
			self.pc.mkfs(part, 'ext4')
			self.pc.mount(part, '/mnt')
		else:
			print('`storage_auto` is not set, skipping partitioning')
			print('Assuming filesystems are mounted on /mnt')

		self.pc.pacstrap('/mnt', ['base'])
		self.pc.genfstab('/mnt', ['-U'], '/mnt/etc/fstab')

		if self.conf['bootloader'] == 'grub':
			self.pc.chroot_install(['grub'])
			self.pc.chroot_configure_loader('grub')
			self.pc.chroot_install_loader('grub', self.conf['bootloader_device'])
		else:
			print(f"Unknown bootloader `{self.conf['bootloader']}`, skipping")

		self.pc.chroot_passwd('root', self.conf.root_passwd)
