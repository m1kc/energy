class Installer(object):
	def __init__(self, conf, pc):
		super(Installer, self).__init__()
		self.conf = conf
		self.pc = pc

	def execute(self):
		bm = self.pc.boot_mode()
		if bm != 'bios':
			print(f'Boot mode is {bm}, but we support only BIOS. Stopping.')
			return

		self.pc.create_pt('sda', 'mbr')
		self.pc.create_partition('sda', 'sda1')
		self.pc.mkfs('sda1', 'ext4')
		self.pc.mount('sda1', '/mnt')

		self.pc.pacstrap('/mnt', ['base'])
		self.pc.genfstab('/mnt', ['-U'], '/mnt/etc/fstab')

		self.pc.chroot_install(['grub'])
		self.pc.chroot_configure_loader('grub')
		self.pc.chroot_install_loader('grub', 'sda')

		self.pc.chroot_passwd('root', '******')
