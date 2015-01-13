all:
	sudo rm -f releng/airootfs/root/install.sh
	cat install.sh | sed "s/echo == //g" | sed "s/;  sleep 1s//g" | sed "s/\"111>>111\"/>>/g" | sed "s/\"111>111\"/>/g" > install-real.sh
	sudo mv install-real.sh releng/airootfs/root/install.sh
	sudo chmod +x releng/airootfs/root/install.sh
	sudo ./releng/build.sh -v -N "energy" -V "0.1" -L "EnergyLinux-0.1"

dirty:
	# Rebuild only i686
	sudo rm -f releng/airootfs/root/install.sh
	cat install.sh | sed "s/echo == //g" | sed "s/;  sleep 1s//g" | sed "s/\"111>>111\"/>>/g" | sed "s/\"111>111\"/>/g" > install-real.sh
	sudo mv install-real.sh releng/airootfs/root/install.sh
	sudo chmod +x releng/airootfs/root/install.sh
	sudo rm -rf work/i686
	sudo rm -fv work/build.make_*_i686
	sudo rm -fv work/build.make_iso_x86_64
	sudo ./releng/build.sh -v -N "energy" -V "0.1" -L "EnergyLinux-0.1"

backup:
	sudo rm -rf out_old/
	sudo mv out out_old

clean:
	sudo rm -rf out/ work/
