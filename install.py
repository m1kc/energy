#!/usr/bin/env python3

import unittest


class DryRun(object):
	def __init__(self, boot_mode):
		super(DryRun, self).__init__()
		self._boot_mode = boot_mode
		self.things = {
			'mounted': None,
			'sda': {
				'table_type': None,
				'has_bootloader': False,
				'bootloader_target': None,
				'partitions': {
					'_xx0': {
						'filesystem': None,
						'has_kernel': False,
						'bootloader_knows_kernel': False,
						'has_fstab': False,
						'has_grub': False,
						'has_root_passwd': False,
					},
				},
			},
		}

	def boot(self, device):
		t = self.things
		assert(t['sda']['table_type'] == 'mbr')
		assert(t['sda']['has_bootloader'] == True)
		assert(t['sda']['bootloader_target'] != None)
		bt = t['sda']['bootloader_target']
		assert(bt in t['sda']['partitions'])
		bt = t['sda']['partitions'][bt]
		assert(bt['has_kernel'])
		assert(bt['bootloader_knows_kernel'])
		assert(bt['has_fstab'])
		assert(bt['has_root_passwd'])

		print('BIOS boot success')
		return True

	def boot_mode(self):
		return self._boot_mode

	def create_pt(self, device, type):
		print('create_pt', device, type)
		self.things[device]['table_type'] = type

	def create_partition(self, device, expected_name):
		print('create_partition', device, expected_name)

		max_part_number = 0
		for i in self.things[device]['partitions']:
			x = int(i[len(device):])
			if x > max_part_number: max_part_number = x
		assert(expected_name == f'{device}{max_part_number+1}')

		self.things[device]['partitions'][expected_name] = {
			'filesystem': None,
			'has_kernel': False,
			'bootloader_knows_kernel': False,
			'has_fstab': False,
			'has_grub': False,
			'has_root_passwd': False,
		}

	def mkfs(self, partition, type):
		print('mkfs', partition, type)
		assert(type == 'ext4')
		self.things['sda']['partitions'][partition]['filesystem'] = type

	def mount(self, partition, mountpoint):
		print('mount', partition, mountpoint)
		assert(self.things['sda']['partitions'][partition]['filesystem'] != None)
		assert(mountpoint == '/mnt')
		self.things['mounted'] = partition

	def pacstrap(self, root_dir, packages):
		print('pacstrap', root_dir, packages)
		assert(self.things['mounted'] != None)
		if 'base' in packages:
			self.things['sda']['partitions']['sda1']['has_kernel'] = True

	def genfstab(self, root_dir, args, filename):
		print('genfstab', root_dir, args, filename)
		assert(self.things['mounted'] != None)
		self.things['sda']['partitions']['sda1']['has_fstab'] = True

	def chroot_passwd(self, login, password):
		print('chroot_passwd', login, password)
		assert(self.things['mounted'] != None)
		assert(login == 'root')
		self.things['sda']['partitions']['sda1']['has_root_passwd'] = True

	def chroot_install(self, packages):
		print('chroot_install', packages)
		assert(self.things['mounted'] != None)
		if 'grub' in packages:
			self.things['sda']['partitions']['sda1']['has_grub'] = True

	def chroot_configure_loader(self, type):
		print('chroot_configure_loader', type)
		assert(type == 'grub')
		assert(self.things['sda']['partitions']['sda1']['has_grub'] == True)
		assert(self.things['sda']['partitions']['sda1']['has_kernel'] == True)
		self.things['sda']['partitions']['sda1']['bootloader_knows_kernel'] = True

	def chroot_install_loader(self, type, device):
		print('chroot_install_loader', type, device)
		assert(type == 'grub')
		assert(self.things['sda']['partitions']['sda1']['has_grub'] == True)
		self.things[device]['has_bootloader'] = True
		self.things[device]['bootloader_target'] = 'sda1'


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


def main():
	conf = {
		'storage_auto': True,
		'root_passwd': '******',
		'bootloader': 'grub',
	}
	pc = DryRun('bios')
	i = Installer(conf, pc)
	i.execute()


class GeneralTest(unittest.TestCase):
	def test_a(self):
		self.assertEqual('foo'.upper(), 'FOO')

	def test_bios(self):
		conf = {
			'storage_auto': True,
			'root_passwd': '******',
			'bootloader': 'grub',
		}
		pc = DryRun('bios')
		i = Installer(conf, pc)
		i.execute()
		pc.boot('sda')


if __name__ == '__main__':
	main()
