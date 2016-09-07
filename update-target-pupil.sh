#!/bin/bash
# This scipt is designed to make updating individual machines on the local network a breeze by using ssh keys and disabling the password for sudo


set -o errexit		# errexit: exit the script if any statement returns a non-true return value
set -o errtrace		# ERR trap is inherited by shell functions
set -o pipefail  	# trace ERR through pipes

if [ "$1" = "" ]; then
	echo "$(tput setaf 1)Please specify the target host as a parameter. $(tput setaf 3)Ex: $0 A01$(tput sgr0)"
	sleep 3
	exit 1
fi

# set target as all lowercase
target=$( echo $1 | tr '[:upper:]' '[:lower:]');

# Copy ssh key to target
ssh-copy-id eba@$target.local


# Hide all startup apps, undoing my previous reveals, doh!
#ssh -t -t eba@$1.local sudo sed -i "s/NoDisplay=false/NoDisplay=true/g" "/etc/xdg/autostart/*.desktop"

# Copy and run the setup scripts
#scp ~/Dropbox/Scripts/{eba-setup-netrun.sh,eba-setup.sh,loaner-setup.sh,set-hostname.sh,ProxyEBA.sh,pupil-setup.sh,configs/10-network-manager.pkla} eba@$target.local:~
#ssh -t -t eba@$target.local bash eba-setup-netrun.sh no-wget
scp -r . eba@$target.local:~
ssh -t -t eba@$target.local bash eba-setup-netrun.sh

### Notification of completion
tput bold
echo "All done updating $target"
tput sgr0
notify-send "All done updating $target"
