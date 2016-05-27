#!/bin/bash

printf "Starting loaner setup... \n"

printf "downloading proxy scripts..."
wget -N -P ~ https://www.dropbox.com/s/frpjsq28q0354sh/ProxyEBA.sh
wget -N -P ~ https://www.dropbox.com/s/161r0r5b4a61gfy/ProxyOff.sh
sudo chmod +x ~/{ProxyEBA.sh,ProxyOff.sh};

printf "setting desktop shortcuts for pupil..."
sudo su -c 'printf "[Desktop Entry]\nType=Application\nName=Proxy On for EBA\nExec=/home/eba/ProxyEBA.sh \nTerminal=true" \
	> /home/pupil/Desktop/ProxyEBA.desktop';
sudo su -c 'printf "[Desktop Entry]\nType=Application\nName=Proxy Off\nExec=/home/eba/ProxyOff.sh \nTerminal=true" \
	> /home/pupil/Desktop/ProxyOff.desktop';
sudo chmod +x /home/pupil/Desktop/{ProxyEBA.desktop,ProxyOff.desktop};

printf "allowing all users to connect to Wifi..."
#sudo sed -i "695s/auth_admin_keep/yes/g" /usr/share/polkit-1/actions/org.freedesktop.NetworkManager.policy
sudo su -c 'printf "[Let pupil modify system settings for network]\nIdentity=unix-user:pupil\nAction=org.freedesktop.NetworkManager.settings.modify.system\nResultAny=no\nResultInactive=no\nResultActive=yes" >  /etc/polkit-1/localauthority/50-local.d/10-network-manager.pkla'

printf "commenting out environment proxy settings..."
sudo sed -i "s/http_proxy/#http_proxy/g" /etc/environment

printf "done! \n"

