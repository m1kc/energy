all:
	sudo rm -f releng/root-image/root/install.sh
	cat install.sh | sed "s/echo == //g" | sed "s/\"111>>111\"/>>/g" | sed "s/\"111>111\"/>/g" > install-real.sh
	sudo mv install-real.sh releng/root-image/root/install.sh
	sudo chmod +x releng/root-image/root/install.sh
	sudo ./releng/build.sh -v -N "energy" -V "0.1" -L "EnergyLinux-0.1"

clean:
	sudo rm -rf out_old/
	sudo mv out out_old
	sudo rm -rf work/
