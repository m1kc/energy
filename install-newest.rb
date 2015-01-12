#!/usr/bin/env ruby

# Basic stuff ==================================================================

def println(x)
	print "#{x}\n"
end

def invoke(x)
	# TODO: release mode
	print "[DEBUG] #{x}"
	system "sleep 1s"
	print "\n"
end

# Dialogs ======================================================================

def enquote(x)
	# TODO: actually do something
	return x
end

def messagebox(x)
	x = enquote(x)
	system "dialog --msgbox '#{x}' 0 0"
end

def infobox(x)
	x = enquote(x)
	system "dialog --infobox '#{x}' 0 0"
end

# Installer utilities ==========================================================

def hdds
	return `ls /dev/sd?`.split("\n")
end

# main =========================================================================

println hdds
