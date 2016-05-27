#!/bin/bash

# Last updated 2015-05-12 13:10:05      
# Sets up and cleans up some things for the pupil user for Edubuntu 12.04 for East Bronx Academy for the Future
# by Kevin McCormack


# Checking for pupil
if [ "$(whoami)" != "pupil" ]; then
	colorprintf red "Sorry, but the elves say you are not pupil.\n"
	sleep 3 && exit
fi


#   ---------- Fucntions -----------
# -------------------------------------

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
		



# -------- Declare variables --------
#-------------------------------------
distro_vers=$(lsb_release -rs);
distro_desc=$(lsb_release -ds);
if [ -e "/usr/share/xsessions/ubuntu.desktop" ]; then
	desktop_env="Unity";
elif [ -e "/usr/share/xsessions/mate.desktop" ]; then
	desktop_env="MATE";
elif [ $XDG_CURRENT_DESKTOP == "LXDE" ]; then
	desktop_env="LXDE";
else
	desktop_env="unknown";
	colorprintf orange "The elves do not recognize this desktop environment! \n";
fi




# 	---- Command sequence starts here ----
# ---------------------------------------------------
# Set bash 
#set -o errexit		# errexit: exit the script if any statement returns a non-true return value
set -o errtrace		# ERR trap is inherited by shell functions
set -o pipefail  	# trace ERR through pipes

# Clear the screen and introduce elves
clear
colorprintf cyan "Welcome to Kevin McCormack's pupil-setup script designed for Ubuntu 12.04 or 14.04 running Unity or MATE! \n"
colorprintf cyan "Waking up the elves to set up the pupil for $desktop_env...\n";


# Set environment and proxy settings for user
printf "Setting the environment and proxy settings for pupil..."
export http_proxy=http://filtr.nycboe.org:8002/
gsettings set org.gnome.system.proxy mode "auto";
gsettings set org.gnome.system.proxy autoconfig-url "http://proxy.nycboe.org/proxy.pac";
colorprintf green "done.\n"


# setup working directory
if [ ! -e ~/.pupil-setup-files ]; then
	mkdir -p ~/.pupil-setup-files/firefox;
	mkdir ~/.pupil-setup-files/chrome;
fi





# Set up desktop environment
case $desktop_env in
	"LXDE")
		printf "Setting up LXDE...";
		sed -i 's/<number>.*<\/number>/<number>1<\/number>/g' ~/.config/openbox/*rc.xml;
		cp /usr/share/applications/{firefox.desktop,google-chrome.desktop,libreoffice-startcenter.desktop} ~/Desktop/;
		colorprintf green "done.\n";;
	"MATE") 
		printf "Setting up MATE..."
		# Set workspaces to 1
		dbus-launch --exit-with-session gsettings set org.mate.Marco.general num-workspaces 1;
		# Set panel objects
		mate-panel --reset &>/dev/null;
		# set desktop app shortcuts
		cp /usr/share/applications/google-chrome.desktop ~/Desktop/
		chmod +x ~/Desktop/google-chrome.desktop
		# disable screenlock
		dbus-launch --exit-with-session gsettings set org.mate.screensaver lock-enabled false;
		dbus-launch --exit-with-session gsettings set org.mate.screensaver mode blank-only;
		# set up mate menu
		#rm ~/*.zip* &>/dev/null
		wget -N -q -P ~/.pupil-setup-files https://www.dropbox.com/s/15wfawhmahl0c2s/desktop-directories.zip
		unzip -u -qq ~/.pupil-setup-files/desktop-directories.zip -d ~/.local/share
		wget -N -q -P ~/.pupil-setup-files https://www.dropbox.com/s/eqbvbqr1r3yo2z1/menus.zip
		unzip -u -qq ~/.pupil-setup-files/menus.zip -d ~/.config
		#rm ~/desktop-directories.zip ~/menus.zip
		colorprintf green "done.\n";;
	"Unity") 
		printf "Setting up Unity...";
		
		if [ "$distro_vers" = "14.04" ]; then
			# Do not display keyboard indicator
			dbus-launch --exit-with-session gsettings set com.canonical.indicator.keyboard visible false;
			# Always show menus for applications
			dbus-launch --exit-with-session gsettings set com.canonical.Unity always-show-menus true;
		fi

		# Do not display user name in panel
		gsettings set com.canonical.indicator.session user-show-menu false;
		# Disable tap to click
		#dbus-launch --exit-with-session gsettings set org.gnome.settings-daemon.peripherals.touchpad tap-to-click false;
		# Set two finger scrolling for touchpads
		gsettings set org.gnome.settings-daemon.peripherals.touchpad scroll-method two-finger-scrolling;
		# Disable automatic screenlock
		gsettings set org.gnome.desktop.screensaver lock-enabled false;
		gsettings set org.gnome.desktop.lockdown disable-lock-screen true;

		# set launcher
		# temp_cron=$(tempfile)
		gsettings set com.canonical.Unity.Launcher favorites "['nautilus-home.desktop', 'firefox.desktop', 'google-chrome.desktop', 'libreoffice-startcenter.desktop', 'audacity.desktop', 'mixxx.desktop', 'kde4-ktouch.desktop', 'gcalctool.desktop']"; # ||  \
			# echo "@reboot env DISPLAY=:0 gsettings set com.canonical.Unity.Launcher favorites \"['nautilus-home.desktop', 'firefox.desktop', 'google-chrome.desktop', 'libreoffice-startcenter.desktop', 'audacity.desktop', 'mixxx.desktop', 'kde4-ktouch.desktop', 'gcalctool.desktop']\"" > $temp_cron && \
			# crontab -u pupil $temp_cron && \
			# colorprintf orange "Set cron job for launcher setup \n";

		# set workspaces to 1x1
		gconftool --set /apps/compiz-1/general/screen0/options/hsize --type=int 1;
		gconftool --set /apps/compiz-1/general/screen0/options/vsize --type=int 1;
		#dbus-launch --exit-with-session gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 1;
		#dbus-launch --exit-with-session gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize 1;

		# Set executable files to run on double click
		gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask';
		colorprintf green "done.\n";;
	*) 
		colorprintf orange "The elves don't know what desktop this is!\n";;
esac


# Set profile picture
cp /usr/share/pixmaps/faces/puppy.jpg ~/.face || colorprintf orange "We couldn't find the profile pic! \n";


# Set power options
printf "Setting the power options for pupil..."
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 3600; # suspend after 1 hour on AC power
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-timeout 1800;
gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action 'nothing';
gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action 'suspend';
# rfkill block bluetooth  # Turn off bluetooth
colorprintf green "done.\n"


# Set java proxy
printf "Setting the Oracle Java proxy..."
if [ ! -e ~/.java/deployment/deployment.properties ]; then
	mkdir -p ~/.java/deployment/
	touch ~/.java/deployment/deployment.properties;
fi
echo "deployment.proxy.auto.config.url=http\://proxy.nycboe.org/proxy.pac" >> ~/.java/deployment/deployment.properties
echo "deployment.proxy.type=2" >> ~/.java/deployment/deployment.properties

colorprintf green "done.\n"


# Reset Firefox and settings
printf "Setting up Firefox..."
#if ps ax | grep -v grep | grep firefox > /dev/null; then
if [ "$(pidof firefox)" ]; then
	killall firefox &>/dev/null;
fi
if [ -e ~/.mozilla/firefox/*.default/ ]; then
	rm -rf ~/.mozilla/firefox/*.default/*
else
	DISPLAY=:0 firefox & sleep 4 
	killall firefox
fi
#rm ~/bookmarks.html* ~/prefs.js* &>/dev/null;
wget -NqP ~/.pupil-setup-files/firefox \
	https://dl.dropboxusercontent.com/u/75661177/pupil/firefox-files/bookmarks.html;
cp ~/.pupil-setup-files/firefox/bookmarks.html ~/.mozilla/firefox/*.default/;

wget -NqP ~/.pupil-setup-files/firefox \
	https://dl.dropboxusercontent.com/u/75661177/pupil/firefox-files/prefs.js;
cp ~/.pupil-setup-files/firefox/prefs.js ~/.mozilla/firefox/*.default/;

colorprintf green "done.\n"


# Reset Google Chrome and settings
printf "Setting up Google Chrome..."
if [ "$(pidof chrome)" ]; then
	killall chrome &>/dev/null;
fi
if [ -d ~/.config/google-chrome ]; then
	rm -rf ~/.config/google-chrome/*
fi
mkdir -p ~/.config/google-chrome/Default
wget -N -q -P ~/.pupil-setup-files/chrome \
	https://dl.dropboxusercontent.com/u/75661177/pupil/google-chrome-files/Bookmarks
cp ~/.pupil-setup-files/chrome/Bookmarks ~/.config/google-chrome/Default

wget -N -q -P ~/.pupil-setup-files/chrome \
	https://dl.dropboxusercontent.com/u/75661177/pupil/google-chrome-files/Preferences
cp ~/.pupil-setup-files/chrome/Preferences ~/.config/google-chrome/Default

colorprintf green "done.\n"




# Disable some startup applications
printf "Disabling some startup apps for pupil..."
mkdir -p ~/.config/autostart && printf "created directory...."

if [ -e ~/.config/autostart/bleachbit.desktop ]; then 
	rm ~/.config/autostart/bleachbit.desktop
fi

if [ -e /etc/xdg/autostart/epoptes-client.desktop ]; then
	printf "epoptes..."
	cp /etc/xdg/autostart/epoptes-client.desktop ~/.config/autostart/ && echo "X-GNOME-Autostart-enabled=false" >> ~/.config/autostart/epoptes-client.desktop
fi

if [ -e /etc/xdg/autostart/jockey-gtk.desktop ]; then
	printf "jockey..."
	cp /etc/xdg/autostart/jockey-gtk.desktop ~/.config/autostart/ && echo "X-GNOME-Autostart-enabled=false" >> ~/.config/autostart/jockey-gtk.desktop
fi

if [ -e /etc/xdg/autostart/telepathy-indicator.desktop ]; then
	printf "telepathy-indicator..."
	cp /etc/xdg/autostart/telepathy-indicator.desktop ~/.config/autostart/ && echo "X-GNOME-Autostart-enabled=false" >> ~/.config/autostart/telepathy-indicator.desktop
fi

if [ -e /etc/xdg/autostart/update-notifier.desktop ]; then
	printf "update-notifier..."
	cp /etc/xdg/autostart/update-notifier.desktop ~/.config/autostart/ && echo "X-GNOME-Autostart-enabled=false" >> ~/.config/autostart/update-notifier.desktop
fi

if grep -qr "X-GNOME-Autostart-enabled" ~/.config/autostart/*.desktop;
then 
	sed -i "s/X-GNOME-Autostart-enabled=true/X-GNOME-Autostart-enabled=false/g" ~/.config/autostart/*.desktop;
else
	echo "X-GNOME-Autostart-enabled=false" >> ~/.config/autostart/*.desktop;
fi
colorprintf green "done.\n"


# Set backgound to be reset at login
if [ "$desktop_env" = "Unity" ]; then
	printf "Setting up background reset at login..."
	touch ~/.config/autostart/gsettings.desktop
	echo "[Desktop Entry]
Type=Application
Exec=gsettings set org.gnome.desktop.background picture-uri \"file:///usr/share/backgrounds/edubuntu_default.png\"
X-GNOME-Autostart-enabled=true
Hidden=false
NoDisplay=true
Name[en_US]=Background Wallpaper Reset
Name=Background Wallpaper Reset
Comment[en_US]=resets backgound at login
Comment=resets backgound at login" > ~/.config/autostart/gsettings.desktop
	colorprintf green "done.\n"
fi


# Run Bleachbit and remove all files from pupil folders
printf "Cleaning up... \n"
# clean off desktop icons
#find ~/Desktop/* ! -name "*.desktop" ! -name Desktop -delete;
#find ~/Desktop/* ! -name "*proxy*" ! -name "*Proxy*" ! -print -delete;
#find ~/Desktop/* -name "pupil-setup.*" -delete;

#rm -rf ~/Documents/* ~/Downloads/* ~/Music/* ~/Pictures/* ~/Videos/* &>/dev/null;

find ~/* ! -name "*proxy*" ! -name "*Proxy*" ! -name "Desktop" ! -name "Documents" \
	! -name "Downloads" ! -name "Music" ! -name "Pictures" ! -name "Public" \
	! -name "Templates" ! -name "Videos" ! -name "examples.desktop" \
	! -name "google-chrome.desktop" ! -name "firefox.desktop" \
	! -name "libreoffice-startcenter.desktop" -print -delete;

bleachbit -c flash.* firefox.* google_chrome.* java.cache system.cache system.desktop_entry \
	system.recent_documents system.tmp system.trash &>/dev/null;

colorprintf green "done.\n"


# Display message and exit
runtime_mins=$(($SECONDS / 60))
runtime_secs=$(($SECONDS % 60))
DISPLAY=:0 notify-send "pupil-setup finished in $runtime_mins min $runtime_secs sec!"
colorprintf green "The elves finished setting up pupil in $runtime_mins min $runtime_secs sec! \u263a \n"
exit

