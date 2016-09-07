#!/bin/bash
# This script sets up a fresh install of Edubuntu 12.04/14.04 for East Bronx Academy for the Future
# The admin account is expected to be eba
# by Kevin McCormack
# -----------------

### Check if this script is running with bash
if [ "$BASH" != "/bin/bash" ]; then
  printf "Please run with ./$0"
  exit 1
fi


#   -------- Fucntions ---------
# ---------------------------------

### Function to check for PPA
# $1 is the string to look for
# $2 is the ppa to add if not found
check_ppa() {
if grep -q $1 /etc/apt/sources.list.d/*; then
	printf "$1 verified..."
else
	sudo -E add-apt-repository -y $2
fi
}


# Function to print in specified color
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


#  -------- Declare variables --------
# -------------------------------------

asset_tag=$(cat "/sys/class/dmi/id/chassis_asset_tag");
bios_vers=$(cat /sys/class/dmi/id/bios_version);
distro=$(lsb_release -is);
distro_vers=$(lsb_release -rs);
distro_desc=$(lsb_release -ds);
kernel_arch=$(uname -i);
kernel_vers=$(uname -r);
model=$(cat "/sys/class/dmi/id/product_name | sed -e 's/^[ \t]*//'");
if [  "$(cat /sys/class/dmi/id/chassis_serial | sed -e 's/^[ \t]*//')" != "" ]; then
	serial_number=$(cat /sys/class/dmi/id/chassis_serial);
elif [ "$(cat /sys/class/dmi/id/board_serial | sed -e 's/^[ \t]*//')" != "" ]; then
	serial_number=$(cat /sys/class/dmi/id/board_serial);
elif [ "$(cat /sys/class/dmi/id/product_serial | sed -e 's/^[ \t]*//')" != "" ]; then
	serial_number=$(cat /sys/class/dmi/id/product_serial);
fi
vendor=$(cat "/sys/class/dmi/id/sys_vendor");
if [ -e "/usr/share/xsessions/ubuntu.desktop" ]; then
	desktop_env="Unity";
elif [ -e "/usr/share/xsessions/mate.desktop" ]; then
	desktop_env="MATE";
elif [ $XDG_CURRENT_DESKTOP == "LXDE" ]; then
	desktop_env="LXDE";
else
	desktop_env="unknown";
	colorprintf orange "The elves do not recognize this desktop environment!\n";
fi

if [ $distro_vers = "12.04" ]; then
	lightdm_config_file="/etc/lightdm/lightdm.conf";
elif [ $distro_vers = "14.04" ]; then
	case $desktop_env in
		"Unity") lightdm_config_file="/usr/share/lightdm/lightdm.conf.d/50-ubuntu.conf";;
		"MATE") lightdm_config_file="/usr/share/lightdm/lightdm.conf.d/50-ubuntu-mate.conf";;
	esac
else
	colorprintf orange "The elves to not recognize this version off Ubuntu!\n";
fi



# 	---- Command sequence starts here ----
#   ---------------------------------------------------
# -------------------------------------------------------

# exec 2> eba-setup-errors.log	# output errors to file
#exec 2> >(while read line; do printf "\n$(tput setaf 1)$line$(tput sgr0)\n" >&2; done)
#set -o errexit		# errexit: exit the script if any statement returns a non-true return value
set -o errtrace		# ERR trap is inherited by shell functions
set -o pipefail  	# trace ERR through pipes


# Intro
clear
colorprintf cyan "Welcome to Kevin McCormack's eba-setup script designed for Ubuntu 12.04 or 14.04 running Unity or MATE! \n"
colorprintf cyan "Waking up the elves for $(hostname)
   Hardware: $model by $vendor
   BIOS Version: $bios_vers
   Asset Tag: $asset_tag   S/N: $serial_number
   OS: $distro_desc with $desktop_env
   Kernel: $kernel_vers $kernel_arch \n"

# Set environment and proxy settings
printf "Checking environment and proxy settings..."
export http_proxy=http://filtr.nycboe.org:8002/
#dbus-launch --exit-with-session gsettings set org.gnome.system.proxy mode "auto";
#dbus-launch --exit-with-session gsettings set org.gnome.system.proxy autoconfig-url "http://proxy.nycboe.org/proxy.pac";
if grep -q "http_proxy" "/etc/environment"; then
	colorprintf green "verified.\n"
else
	# add http_proxy to last line of /etc/environment file
	sudo sed -i '$a http_proxy=http://filtr.nycboe.org:8002/' /etc/environment;
	colorprintf green "set.\n"
fi

# Set local policy for modifying network settings
printf "Setting local network policies..."
#wget -N -q -P ~ https://www.dropbox.com/s/ooxd642izs1px68/10-network-manager.pkla
#sudo cp ~/10-network-manager.pkla /etc/polkit-1/localauthority/50-local.d/
sudo cp ~/eba-setup-scripts/configs/10-network-manager.pkla /etc/polkit-1/localauthority/50-local.d/
colorprintf green "done.\n"

# Set swappiness
printf "Checking swappiness..."
if grep -q "vm.swappiness" "/etc/sysctl.conf"; then
	colorprintf green "verified.\n"
else
	# add swappiness setting to last line of /etc/sysctl.conf
	sudo sed -i '$a vm.swappiness=10' /etc/sysctl.conf;
	colorprintf blue "set to 10.\n"
fi


# Set brightness
printf "Optimizing screen brightness..."
if [ -f /sys/class/backlight/acpi_video0/max_brightness ]; then
	brightness_file="/sys/class/backlight/acpi_video0/brightness"
	optimal_brightness=$(($(cat /sys/class/backlight/acpi_video0/max_brightness)/2));
else
	optimal_brightness=0
fi

if [ "$optimal_brightness" -gt "0" ]; then
	sudo sed -i '13cecho '$optimal_brightness' > '$brightness_file /etc/rc.local
	colorprintf green "set to $optimal_brightness\n"
else
	colorprintf orange "optimal brightness unknown!\n"
fi

# Set profile picture
cp /usr/share/pixmaps/faces/cat-eye.jpg ~/.face || colorprintf orange "We couldn't find the profile pic! \n";

# Set launcher icons and executable file settings
<<COMMENT
if [ "$desktop_env" = "Unity" ]; then
	printf "Setting the launcher icons for EBA user..."
	dbus-launch --exit-with-session gsettings set com.canonical.Unity.Launcher favorites "['nautilus-home.desktop', 'firefox.desktop', 'google-chrome.desktop', 'ubuntu-software-center.desktop', 'software-properties-gtk.desktop', 'gnome-system-monitor.desktop', 'gnome-terminal.desktop']";
	colorprintf green "done.\n"
	# Set to ask about executable files on double click
	dbus-launch --exit-with-session gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask';
fi
COMMENT

# Disable Apport error reporting
sudo sed -i "s/enabled=1/enabled=0/g" /etc/default/apport

# Disable prompting for upgrading to new versions of Ubuntu
sudo sed -i '17s/.*/Prompt=never/' /etc/update-manager/release-upgrades
if [ -e "/var/lib/update-notifier/release-upgrade-available" ]; then
	sudo rm /var/lib/update-notifier/release-upgrade-available
fi

# Set update schedule for security updates and autoclean
printf "Checking update and autoclean schedules..."
if grep -q "APT::Periodic::Unattended-Upgrade \"1\";" "/etc/apt/apt.conf.d/10periodic"; then
	colorprintf green "verified.\n"
else
	sudo sed -i 's/Update-Package-Lists ".*";/Update-Package-Lists "1";/' /etc/apt/apt.conf.d/10periodic
	sudo sed -i 's/Download-Upgradeable-Packages ".*";/Download-Upgradeable-Packages "1";/' /etc/apt/apt.conf.d/10periodic
	sudo sed -i 's/AutocleanInterval ".*";/AutocleanInterval "7";/' /etc/apt/apt.conf.d/10periodic
	sudo sed -i 's/Unattended-Upgrade ".*";/Unattended-Upgrade "1";/' /etc/apt/apt.conf.d/10periodic
	colorprintf green "set.\n"
fi


# Check and remove Ubuntu One
printf "Checking for Ubuntu One..."
if type ubuntuone-installer &>/dev/null;
then
	printf "removing..."
	killall ubuntuone-login ubuntuone-preferences ubuntuone-syncdaemon
	rm -rf ~/.local/share/ubuntuone
	rm -rf ~/.cache/ubuntuone
	rm -rf ~/.config/ubuntuone
	sudo apt -qq purge ubuntuone-client ubuntuone-installer python-ubuntuone-storage*
	colorprintf blue "removed.\n"
else
	colorprintf green "verified gone.\n"
fi


#Disable guest account
printf "Checking the guest account..."
if grep -q "allow-guest=false" "$lightdm_config_file"; then
	colorprintf green "verified disabled.\n"
else
	sudo sed -i '$a allow-guest=false' "$lightdm_config_file";
	colorprintf blue "disabled.\n"
fi


# Add the pupil user and set auto login
printf "Setting up the pupil user..."
if (lastlog | grep -q "pupil") then
	printf "existance verified..."
else
	#sudo useradd -m -G nopasswdlogin -s /bin/bash -p pupil pupil
	#sudo adduser --ingroup nopasswdlogin pupil;
	sudo adduser --disabled-password --ingroup nopasswdlogin --gecos "Pupil" pupil;
	printf "pupil:pupil" | sudo chpasswd;
	sudo su pupil -c 'mkdir /home/pupil/Desktop'
	sudo su pupil -c 'printf "[Desktop Entry]\nType=Application\nExec=/home/eba/pupil-setup.sh\nTerminal=true" > /home/pupil/Desktop/pupil-setup.desktop;'
	sudo chmod +x /home/pupil/Desktop/pupil-setup.desktop
	printf "created account...";
fi
# set up autologin to pupil
if (grep -q "autologin-user=pupil" "$lightdm_config_file") then
	printf "autologin verified..."
else
	sudo sed -i '$a autologin-user=pupil' $lightdm_config_file;
	printf "autologin set..."
fi
colorprintf green "verified gone.\n"


# Check and add TLP for power savings, Oracle Java, and Mixxx PPAs
printf "Checking PPAs..."
check_ppa java ppa:webupd8team/java;
#check_ppa mixxx ppa:mixxx/mixxx;
check_ppa tlp ppa:linrunner/tlp;
check_ppa openscad ppa:openscad/releases;
check_ppa atom ppa:webupd8team/atom;

colorprintf green "done.\n"


# Update the package lists and check for errors
printf "The elves are updating the package lists..."
sudo rm -rf /var/lib/apt/lists/* -f
tput setaf 7 # gray
sudo -E apt -qq update || sudo -E apt update
tput sgr0 # reset color
colorprintf green "done.\n"


# Remove the messaging and other applications
printf "Removing messaging and internet apps... \n"
tput setaf 7	# gray
sudo apt -qq remove deja-dup indicator-messages empathy gwibber steam thunderbird transmission-gtk pidgin
if [ "$desktop_env" = "MATE" ]; then
	sudo apt -qq remove hexchat
elif [ "$desktop_env" = "Unity" ]; then
	sudo apt -qq remove landscape-* webbrowser-app unity-control-center-signon
fi
colorprintf green "done.\n"


# Check and Install Google Chrome
printf "Checking Google Chrome..."
if [ -e /usr/share/applications/google-chrome.desktop ]; then
	colorprintf green "verified.\n"
else {
	printf "downloading...\n"
	if [ "$kernel_arch" = "x86_64" ]; then
		wget -N https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	else
		wget -N https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb

	fi
	printf "installing...\n"
	sudo dpkg -i google-chrome-stable_current_*.deb || sudo -E apt -f install;
	colorprintf blue "installed.\n"
}
fi


# Download and install BleachBit 1.6 if Ubuntu 12.04
if [ "$distro_vers" = "12.04" ]; then
	printf "Checking Bleachbit..."
	if [ "$(bleachbit --version 2>/dev/null | grep -c 'version 1.6')" = "0" ]; then
		colorprintf blue "downloading...\n"
		wget -P ~/Downloads http://katana.oooninja.com/bleachbit/sf/bleachbit_1.6_all_ubuntu1204.deb
		colorprintf blue "installing...\n"
		sudo dpkg -i ~/Downloads/bleachbit_1.6_all_ubuntu1204.deb || sudo apt install -f -y
		rm ~/Downloads/bleachbit_1.6_all_ubuntu1204.deb
	fi
	colorprintf green "done.\n"
fi



# Accept EULA for Microsoft fonts and Oracle Java
printf "Setting up EULA for MS fonts and Oracle Java..."
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
colorprintf green "done.\n";


# Install English and Spanish packages to complete language files and emoticons
printf "The elves are installing language packages..."
sudo -E apt -y -qq install ttf-ancient-fonts hyphen-en-us mythes-en-us firefox-locale-es gimp-help-es language-pack-es language-pack-gnome-es libreoffice-help-es libreoffice-l10n-es myspell-es wspanish;
colorprintf green "done.\n";


# Set up English US and Spanish US, DR, PR and Honduras and re-generate locales
printf "Setting up locales..."
echo "en_US.UTF-8 UTF-8" | sudo tee /var/lib/locales/supported.d/en 1>/dev/null;
echo 	"es_DO.UTF-8 UTF-8
	es_HN.UTF-8 UTF-8
	es_MX.UTF-8 UTF-8
	es_PR.UTF-8 UTF-8
	es_ES.UTF-8 UTF-8
	es_US.UTF-8 UTF-8" | sudo tee /var/lib/locales/supported.d/es 1>/dev/null;
sudo rm -rfv /usr/lib/locale/* 1>/dev/null;
sudo locale-gen 1>/dev/null;
colorprintf green "done.\n";


# Install some software
printf "The elves are installing more cool stuff..."
sudo -E apt -qq install bleachbit openssh-server oracle-java7-installer audacity mixxx libportaudio2 vlc gimp musescore openshot openscad edubuntu-artwork ubuntu-edu-secondary ubuntu-restricted-extras python-appindicator tlp tlp-rdw atom;
# install Edubuntu artwork if Unity
if [ "$desktop_env" = "Unity" ]; then
	printf "installing edubuntu-artwork..."
	sudo -E apt -qq install edubuntu-artwork
	colorprintf "done.\n"
fi
colorprintf green "done.\n";


# Check and Enable Restricted Format DVD Playback
printf "Checking for restricted fromat DVD playback ability..."
if [ "$(dpkg -l libdvdcss2 | grep -c 'ii')" = "1" ]; then
	colorprintf green "verified.\n";
else
	sudo -E /usr/share/doc/libdvdread4/install-css.sh
	colorprintf blue "enabled.\n";
fi


# Cleanup
printf "The elves are taking out their brooms..."
sudo bleachbit -c apt.* flash.* system.cache system.desktop_entry system.rotated_logs system.tmp system.trash &>/dev/null
colorprintf green "done.\n";


# Display message and exit
clear
runtime_mins=$(($SECONDS / 60))
runtime_secs=$(($SECONDS % 60))
DISPLAY=:0 notify-send "The elves finished $0 in $runtime_mins min $runtime_secs sec!"
colorprintf green "The elves finished $0 on $(hostname) in $runtime_mins min $runtime_secs sec! \u263a \n"
exit
