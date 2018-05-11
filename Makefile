all: iso

copy-installer:
	sudo rm -f releng/airootfs/root/install.py
	sudo rm -rf releng/airootfs/root/installer

	sudo cp ./install.py releng/airootfs/root/
	sudo cp -r ./installer releng/airootfs/root/

	sudo cp ./bleeding-edge.sh releng/airootfs/root/

# Regular full build
iso: copy-installer
	sudo ./releng/build.sh -v -N "energy" -V "0.1" -L "EnergyLinux-0.1"

# Replace installer, take other stuff from the last full build
iso-fast: copy-installer
	sudo rm work/build.{make_prepare,make_iso,make_customize_airootfs,make_boot,make_boot_extra,make_syslinux,make_isolinux,make_efi,make_efiboot}_x86_64
	sudo ./releng/build.sh -v -N "energy" -V "0.1" -L "EnergyLinux-0.1"

backup:
	sudo rm -rf out_old/
	sudo mv out out_old

clean:
	sudo rm -rf out/ work/


test:
	python -m unittest -v -b installer/test*
