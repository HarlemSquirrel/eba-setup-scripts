#!/bin/bash
# This script downloads and runs the eba-setup and pupil-setup scripts


### Function to print in specified color
colorprintf () {
	case $1 in
		"red") tput setaf 1;;
		"green") tput setaf 2;;
		"orange") tput setaf 3;;
		"blue") tput setaf 4;;
		"purple") tput setaf 5;;
		"cyan") tput setaf 6;;
		"gray" | "grey") tput setaf 7;;
		"white") tput setaf 8;;
	esac
	printf "$2";
	tput sgr0
}




### Download scripts unless run with no-wget argument
if [ "$1" != "no-wget" ]; then
	printf blue "Downloading scripts... \n"
	export http_proxy=http://filtr.nycboe.org:8002/
	if ! hash git 2>/dev/null; then
		sudo apt install -y git;
	fi

	# git pull or clone scripts
	if [[ -e ~/eba-setup-scripts ]]; then
		cd ~/eba-setup-scripts && git pull
	else
		git clone https://github.com/HarlemSquirrel/eba-setup-scripts.git ~/eba-setup-scripts
	fi

	#wget -N -P ~ https://www.dropbox.com/s/hxjxhnic6qtz7zz/eba-setup-netrun.sh;
	#wget -N -P ~ https://www.dropbox.com/s/4waghtjp6tc30fw/set-hostname.sh;
	#wget -N -P ~ https://www.dropbox.com/s/gzi4g7fwe42aj34/pupil-setup.sh;
	#wget -N -P ~ https://www.dropbox.com/s/frpjsq28q0354sh/ProxyEBA.sh
	#wget -N -P ~ https://www.dropbox.com/s/vy3g26umr74ciub/loaner-setup.sh;

	colorprintf green "done. \n"
fi
#chmod +x ~/pupil-setup.sh
chmod +x ~/eba-setup-scripts/pupil-setup.sh


### Set proxy settings to at EBA
#sudo bash ~/ProxyEBA.sh
sudo bash ~/eba-setup-scripts/ProxyEBA.sh


#if [ $? -ne 0 ]; then
#	colorprintf red "No go, buddy.\n"
#	exit 1;
#else
#	colorprintf green "done.\n"
#fi

### Setup Prompts
read -n 1 -t 10 -p "Setup as a loaner? (y/N) " set_as_loaner;
printf "\n"
if [ "$set_as_loaner" == "Y" ] || [ "$set_as_loaner" == "y" ]; then
	# Run eba-setup and so a full upgrade for loaners
	run_eba_setup="y";
	full_upgrade="y";
else
	#if [ ! -e "/etc/xdg/autostart/studentwnd.desktop" ]; then
	#	read -n 1 -t 10 -p "Would you like to download and install LanSchool student? (y/N) " install_LS;
	#	printf "\n"
	#else
	#	colorprintf blue "LanSchool seems to be already installed. \n"
	#fi

	read -n 1 -t 10 -p "Would you like to run eba-setup.sh? (y/N) " run_eba_setup;
	printf "\n"
	#read -n 1 -t 10 -p "Would you like to run pupil-setup.sh? (y/N) " run_pupil_setup;
	#printf "\n"
	read -n 1 -t 10 -p "Download and upgrade all packages? (y/N) " full_upgrade;
	printf "\n \n"
fi
#read -n 1 -t 10 -p "Would you like to specify a new hostname? (y/N) " specify_new_hostname;
#desired_new_hostname="";
#if [ "$specify_new_hostname" = "y" -o "$specify_new_hostname" = "Y" ]; then
#	read -p "Enter the new hostname: " desired_new_hostname;
#fi
#printf "\n"



### Check for and disable sudo password for eba
printf "Checking sudo password..."
if sudo grep -q "eba ALL=(ALL) NOPASSWD: ALL" "/etc/sudoers"; then
	colorprintf green "verified disabled.\n"
else
	echo "eba ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
	colorprintf blue "disabled.\n"
fi


### Setup LanSchool
# Download and install LanSchool student
<<LANSCHOOL
if [ "$install_LS" == "y" ]; then
	printf "starting LanSchool setup...\n"
	LS_channel=0;
	until [[ "$LS_channel" -gt 0 ]]; do
		read -p "What LS channel (room number)? " LS_channel;
	done
	printf "\n Downloading LanSchool student...\n"
	tput setaf 7 # gray
	wget -N -P ~ https://www.dropbox.com/s/047ds63bexi0ker/student-Ubuntu.run
	colorprintf white "installing with channel $LS_channel...\n"
	sudo bash ~/student-Ubuntu.run -a -c $LS_channel -q && colorprintf blue "installed.\n"
	tput sgr0 # reset color
	rm ~/student-Ubuntu.run*
	# Hide lanschool from Startup GUI
	sudo sed -i '$a NoDisplay=true' /etc/xdg/autostart/studentwnd.desktop;
	#echo "NoDisplay=true" | sudo tee -a /etc/xdg/autostart/studentwnd.desktop;
	colorprintf blue "hidden from the startup menu.\n"
fi
LANSCHOOL

### eba-setup
eba_setup_errors=0
if [ "$run_eba_setup" = "y" -o "$run_eba_setup" = "Y" ]; then
	#if [ "$1" != "no-wget" ]; then
	#	wget -N -P ~ https://www.dropbox.com/s/ob66mndq6ogwdoo/eba-setup.sh;
	#fi
	printf "starting eba-setup...\n"
	#bash ~/eba-setup.sh
	bash ~/eba-setup-scripts/eba-setup.sh
	eba_setup_errors=$?
	if [ $eba_setup_errors -ne 0 ];
	then
		colorprintf red "\n \t eba-setup.sh had $eba_setup_errors error(s)! \n"
	fi
	#rm eba-setup.sh*
fi


### pupil-setup
pupil_setup_errors=0
if [ "$run_pupil_setup" = "y" -o "$run_pupil_setup" = "Y" ]; then
	chmod +x ~/pupil-setup.sh
	printf "\n  starting pupil-setup...\n"
	#sudo -H -u pupil bash ~/pupil-setup.sh
	sudo -H -u pupil bash ~/eba-setup-scripts/pupil-setup.sh
	#sudo su pupil -c "rm -r ~/.mozilla/firefox/*.default && DISPLAY=:0 firefox & sleep 3 && ./pupil-setup.sh"
	pupil_setup_errors=$?
	if [ $pupil_setup_errors -ne 0 ]; then
		colorprintf red "\n \t pupil-setup had $pupil_setup_errors error(s)! \n"
	fi
fi


### Loaner setup
if [ "$set_as_loaner" = "y" -o "$set_as_loaner" = "Y" ]; then
	colorprintf blue "Setting up this machine as a loaner..."
	#bash ~/loaner-setup.sh;
	bash ~/eba-setup-scripts/loaner-setup.sh
	colorprintf green "done. \n";
fi


### Full system upgrade
full_upgrade_errors=0
if [ "$full_upgrade" = "y" -o "$full_upgrade" = "Y" ]; then
	printf "\n  starting full system upgrade...\n"
	sudo -E apt-get -qq update;
	#sudo -E apt-get -f -y dist-upgrade;
	sudo DEBIAN_FRONTEND=noninteractive dpkg --force-confold --force-confdef --configure -a
	sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" \
		-o Dpkg::Options::="--force-confold" dist-upgrade
	full_upgrade_errors=$?;
	sudo apt-get -qq autoremove;
	if [ $full_upgrade_errors -ne 0 ]; then
		colorprintf red "\n \t the full upgrade had $full_upgrade_errors error(s)! \n";
	else
		colorprintf green "done.\n";
	fi
fi


### Run set-hostname script
set_hostname_errors=0
#sudo bash ~/set-hostname.sh $desired_new_hostname;
sudo bash ~/eba-setup-scripts/set-hostname.sh $desired_new_hostname;
set_hostname_errors=$?;
if [ $set_hostname_errors -ne 0 ]; then
	colorprintf red "\n \t set-hostname had $set_hostname_errors error(s)! \n"
fi


### Finish and prompt for action
total_errors=$(($eba_setup_errors+$pupil_setup_errors+$set_hostname_errors+$full_upgrade_errors))
if [ $total_errors -gt 0 ]; then
	colorprintf red "\n \t All done running sciprts, but we encountered $total_errors error(s)! \n"
else
	colorprintf green "\n \t All done running sciprts, and we encountered no errors! \n"
fi

read -n 1 -t 60 -p "Would you like to shutdown, reboot, or exit? (s/r/Q) " exit_option || printf "quitting...\n";
printf "\n"

case $exit_option in
	s|S)
		DISPLAY=:0 notify-send "Powering off in 3 seconds";
		printf "System is powering off in 3..$(sleep 1)2..$(sleep 1)1..$(sleep 1)";
		sudo pkill -KILL -u pupil && sudo poweroff;;
	r|R)
		DISPLAY=:0 notify-send "Rebooting for maintenance in 3 seconds";
		printf "System is rebooting in 3..$(sleep 1)2..$(sleep 1)1..$(sleep 1)";
		sudo pkill -KILL -u pupil && sudo reboot;;
	*)
		exit;;
esac