#!/usr/bin/env python3

from installer.emulator import Emulator
from installer.system import RealSystem
from installer.core import Installer

import unittest


def main():
	conf = {
		'storage_auto': True,
		'root_passwd': '******',
		'bootloader': 'grub',
	}
	# pc = Emulator('bios')
	pc = RealSystem()
	i = Installer(conf, pc)
	i.execute()


if __name__ == '__main__':
	main()
