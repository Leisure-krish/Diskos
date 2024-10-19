#! /usr/bin/bash

#Made by Anurag Yadav.

# BASH menu script that :
#   - Verify Disk Health
#   - View all Disk Partition
#   - Smartctl check
#   - Benchmark

server_name=$(hostname)

# Root check
function root_check () {
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit 1
fi
}

# Smartctl tool check 
function tool_check () {
	if ! [ -x "$(command -v smartctl)" ]; then
  echo 'Error: smartctl is not installed.' >&2
exit 1
  else echo -ne "Smartctl found, You can proceed! \n \n" 
fi
}

# List available disks and partitions
function list_disks() {
    echo "Available disks:"
    lsblk -d | awk '{print $1}' | tail -n +2
}

# User Input
function disk_sel () {
    echo ""
	echo "Input Disc Name (Eg - sda, sdb) :"  
read disk   

echo "Partition number: (Eg - 2,3) :"  
read part 
	echo ""
}

##
# Main-menu functions
##

function empty () {
    echo ""
	echo "Disks Space Status on ${server_name} is: "
	echo ""
	df -h
	echo ""
}

function disk_health () {
        echo ""
	echo "Disk Health Status on ${server_name} is: "
	echo ""
 	echo ""
	smartctl -i /dev/${disk}
	echo ""
}

function disk_part () {
    echo ""
	echo "Disk Partition on ${server_name} is: "
    echo ""
	fdisk -l
    echo ""
}

function smart_check() {
    echo ""
	echo "Quick Smart Check  on ${server_name}: "
    echo ""
 if	
 badblocks -sv /dev/${disk}${part} -o Bad_Blocks.md then smartctl -H /dev/${disk}
 else 
 echo "Error running badlocks. Check your disk and partition."
 fi
    echo ""
}

function bench_mark () {
    echo ""
	echo "Benchmarking on disk ${disk} partition ${part} on ${server_name} : "
	echo ""
#	export disk=${disk}
#export part=3
echo "Test size for benchmark in MB () "  
read testsize

#export testsize=100 # in megabytes
cd /tmp || { echo "Failed to change the directory to /tmp"; exit 1; }
rmdir mntbench 2>/dev/null
mkdir mntbench
mount /dev/${disk}${part} ./mntbench
if ! mount /dev/${disk}${part} ./mntbench; then
echo "Error: Unable to mount /dev/${disk}${part}. Please check the device."
exit 1
fi
cd mntbench || { echo "Failed to change directory to mntbench"; exit 1; }
dd if=/dev/zero of=temp oflag=direct bs=1048576 count="${testsize}" status=progress
rm temp
cd ..
umount ./mntbench
rmdir mntbench

    echo ""
}

function all_checks() {
	empty
	disk_health 
	disk_part 
	smart_check
	bench_mark
}

##
# Color  Variables
##

green='\e[32m'
blue='\e[34m'
clear='\e[0m'

##
# Color Functions
##

ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}
## Help
function show_help() {
    echo "Help Section:"
    echo "1) Verify Disk Health - Checks the SMART status of the disk."
    echo "2) View all Disk Partition - Lists all partitions on the disks."
    echo "3) Quick Smartctl Check - Performs a quick SMART check on the selected partition."
    echo "4) Benchmark - Runs a benchmark on the selected disk partition."
    echo "5) Check All - Runs all available checks."
    echo "6) Select Disk & Partition - Choose which disk and partition to work with."
    echo "7) Disk Space Result (ONLY MOUNTED) - Shows the disk space usage of mounted partitions."
    echo "0) Exit - Exit the script."
##
# Main-menu
##

menu(){
													# Tool check function call
echo -ne "
$(ColorGreen '1)') Verify Disk Health
$(ColorGreen '2)') View all Disk Partition
$(ColorGreen '3)') Quick Smartctl Check 
$(ColorGreen '4)') Benchmark
$(ColorGreen '5)') Check All
$(ColorGreen '6)') Select Disk & Partition
$(ColorGreen '7)') Disk Space Result (ONLY MOUNTED)
$(ColourGreen '8)') Help
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) disk_health  ; menu ;;
	        2) disk_part  ; menu ;;
	        3) smart_check ; menu ;;
	        4) bench_mark  ; menu ;;
	        5) all_checks ; menu ;;
			6) disk_sel ; menu ;;
			7) empty ; menu ;;
   			8) show_help; menu ;;
		0) exit 0 ;;
		*) echo -e $red"Wrong option."$clear; WrongCommand;;
        esac
}

# Call the menu function
echo -ne "Diskos \n "
root_check
tool_check
echo -ne "If you do not know you Disk and Partition, Press Enter \n  and use Option 2 (View all Disk Partition) to know your Disk and Partition \n Use Option 6 (Select Disk & Partition) to select. \n "
disk_sel
menu
