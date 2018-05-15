import subprocess

def invoke(*args, **kwargs):
	return subprocess.run(*args, **kwargs, check=True)

class RealSystem(object):
	def __init__(self):
		super(RealSystem, self).__init__()

	def boot_mode(self):
		try:
			invoke(['ls', '/sys/firmware/efi/efivars/'])
			return 'uefi'
		except:
			return 'bios'

	def create_pt(self, device, type):
		if type != 'mbr':
			raise ValueError('Non-MBR partition tables are not supported')
		invoke(['dd', 'if=/dev/zero', 'of=/dev/'+device, 'bs=1M', 'count=10'])
		script = '\n'.join([
			'label: dos',  # MBR
			',',  # Whole-disk partition
			'write',
		])
		invoke(['sfdisk', '/dev/'+device], input=script)

	def create_partition(self, device, expected_name):
		pass

	def mkfs(self, partition, type):
		pass

	def mount(self, partition, mountpoint):
		pass

	def pacstrap(self, root_dir, packages):
		pass

	def genfstab(self, root_dir, args, filename):
		pass

	def chroot_passwd(self, login, password):
		pass

	def chroot_install(self, packages):
		pass

	def chroot_configure_loader(self, type):
		pass

	def chroot_install_loader(self, type, device):
		pass
