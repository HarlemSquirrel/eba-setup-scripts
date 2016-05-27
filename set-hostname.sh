#!/bin/bash
# Last updated 2014-11-14 10:14:36 
# This script sets the host name for Ubuntu 12.04 and must be run by a user with sudo privileges
# sudo sh sethostname.sh <newhostname>
# Kevin McCormack

## Get asset tag, model, and serial number
host_asset_tag=$(cat /sys/class/dmi/id/chassis_asset_tag | sed -e 's/^[ \t]*//');
host_product_name=$(cat /sys/class/dmi/id/product_name);
if [  "$(cat /sys/class/dmi/id/chassis_serial | sed -e 's/^[ \t]*//')" != "" ]; then
	host_serial_number=$(cat /sys/class/dmi/id/chassis_serial);	
elif [ "$(cat /sys/class/dmi/id/board_serial | sed -e 's/^[ \t]*//')" != "" ]; then
	host_serial_number=$(cat /sys/class/dmi/id/board_serial);
elif [ "$(cat /sys/class/dmi/id/product_serial | sed -e 's/^[ \t]*//')" != "" ]; then
	host_serial_number=$(cat /sys/class/dmi/id/product_serial);
fi

## Set new hostname with serial number as the priority
if [ "$host_serial_number" != "" ] && [ "$host_serial_number" != "0" ]; then
	new_hostname=$host_serial_number;
elif [ "$host_asset_tag" != "" ]; then
	new_hostname=$host_asset_tag;
else
	new_hostname=$host_product_name;
fi


# Checking for root
if [ "$(whoami)" != "root" ]; then
	echo "$(tput setaf 1)Sorry, but the elves will not answer to you.$(tput sgr0)" # red
	exit 2
fi


# Check for Cart E serial numbers
case $host_serial_number in
	"CNU11112F4") new_hostname="E01";;
	"CNU1141L7L") new_hostname="E02";;
	"CNU1140T74") new_hostname="E03";;
	"CNU1141KRW") new_hostname="E04";;
	"CNU1141LHJ") new_hostname="E05";;
	"CNU11112M4") new_hostname="E06";;
	"CNU1150RBS") new_hostname="E07";;
	"CNU11510J6") new_hostname="E08";;
	"CNU1150X7C") new_hostname="E09";;
	"CNU1150Y6H") new_hostname="E10";;
	"CNU1151HT7") new_hostname="E11";;
	"CNU1150XJ5") new_hostname="E12";;
	"CNU1150WCC") new_hostname="E13";;
	"CNU1150XZR") new_hostname="E14";;
	"CNU1151081") new_hostname="E15";;
	"CNU1151LL4") new_hostname="E16";;
	"CNU1150ZNP") new_hostname="E17";;
	"CNU1151J49") new_hostname="E18";;
	"CNU1151H43") new_hostname="E19";;
	"CNU1150WQS") new_hostname="E20";;
	"CNU1150X7Q") new_hostname="E21";;
	"CNU1150RCX") new_hostname="E22";;
	"CNU1150WBF") new_hostname="E23";;
	"CNU1150QN2") new_hostname="E24";;
	"CNU1151J8X") new_hostname="E25";;
	"CNU1150RJB") new_hostname="E26";;
	"CNU1151HZC") new_hostname="E27";;
	"CNU1150VNL") new_hostname="E28";;
	"CNU115104C") new_hostname="E29";;
	"CNU1150RJ5") new_hostname="E30";;
	"CNU1150WLN") new_hostname="E31";;
	"CNU11510HH") new_hostname="E32";;
	"CNU1151049") new_hostname="E33";;
	"CNU1150WJN") new_hostname="E34";;
	"CNU1150VNN") new_hostname="E35";;
esac


# Check for specified hostname
if [ $# -gt 1 ]; then
	echo 1>&2 "$0: $(tput setaf 1)Please include only one host name$(tput sgr0)"
	exit 2
elif [ $# -eq 1 ]; then
	new_hostname=$1;
fi


# Set new hostname
sed -i "1s/.*/$new_hostname/" /etc/hostname
sed -i "2s/.*/127.0.1.1       $new_hostname/" /etc/hosts;
hostname $new_hostname &>/dev/null;


# Report back
echo "$(tput setaf 2)The elves have set the new host name as $(tput sgr0) $(hostname)"
