#!/bin/bash
set -e
set -x

if [ -z "$1" ]; then
	echo Must provide a branch. Stopping.
	exit
fi

rm -f "$1.zip"
rm -rf "energy-$1"
rm -f install.py
rm -rf installer

which unzip || pacman -Sy --noconfirm unzip
wget "https://github.com/m1kc/energy/archive/$1.zip"
unzip "$1.zip"
cd "energy-$1"
mv install.py ..
mv installer ..
