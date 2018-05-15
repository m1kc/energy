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
		except e:
			return 'bios'
