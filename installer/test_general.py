#!/usr/bin/env python3

from .emulator import Emulator
from .core import Installer

import unittest


class GeneralTest(unittest.TestCase):
	def test_a(self):
		self.assertEqual('foo'.upper(), 'FOO')

	def test_bios(self):
		conf = {
			'storage_auto': True,
			'root_passwd': '******',
			'bootloader': 'grub',
		}
		pc = Emulator('bios')
		i = Installer(conf, pc)
		i.execute()
		pc.boot('sda')
