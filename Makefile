all:
	@if [ "`whoami`" "!=" "root" ]; then echo Requires root privileges.; exit 1; fi 
	mkarchiso init
