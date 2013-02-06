all:
	sudo rm -f releng/root-image/root/install.sh
	sudo cp install.sh releng/root-image/root/install.sh
	sudo ./releng/build.sh -v -N "energy" -V "0.1" -L "EnergyLinux-0.1"
