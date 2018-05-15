import subprocess

def invoke(*args, **kwargs):
	kwargs['check'] = True
	if 'input' in kwargs:
		kwargs['input'] = kwargs['input'].encode('utf-8')
	return subprocess.run(*args, **kwargs)

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
			'write',
		])
		invoke(['sfdisk', '/dev/'+device], input=script)

	def create_partition(self, device, expected_name, start=None, size=None, type=None, bootable=False):
		# TODO: check if expected_name is sane
		script = '\n'.join([
			',',  # Whole-disk partition, TODO: actually use input params
			'write',
		])
		invoke(['sfdisk', '/dev/'+device], input=script)
		# TODO: check if expected_name matched

	def mkfs(self, partition, type):
		invoke(['mkfs.'+type, '/dev/'+partition])

	def mount(self, partition, mountpoint):
		invoke(['mount', '/dev/'+partition, mountpoint])

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
