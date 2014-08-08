#!/bin/bash

##
##	CONFIGURATION
##

script="$0"
if [[ "$(echo "/$(ls -ld $0 | cut -d '/' -f 2-)" | grep -)" != "" ]]; then
	script=$(echo "/$(ls -ld $0 | cut -d '/' -f 2-)" | grep - | cut -d '>' -f 2- | cut -c 2-)
fi
script_directory=$(echo `dirname $script`)

configfile="$script_directory/media_server.cfg"
if [[ -f "$configfile" ]]; then echo "
Found config file:		$configfile
" >&2 && source "$configfile"; else echo "
Could not find config file. Are all the relevant scripts and files in the right directory?
" >&2 && exit 1; fi

##
##	FUNCTIONS
##

# Checks the OS being used
check_os () {
	if [ "$(uname)" = "Darwin" ]; then
		OS="Mac"
		HandBrakeCLI="$handbrake_location/HandBrakeCLI"
	elif [ "$(uname)" = "Linux" ]; then
		OS="Linux"
		HandBrakeCLI=$(whereis HandBrakeCLI | cut -d ' ' -f 2)
	else
		echo "Your Operating System is not supported. Please request support via GitHub. If you feel there is an issue, please post it on GitHub."
		exit
	fi
}

# Install transmission-daemon for Mac (includes MacPorts, and agreeing to Xcode's license agreement)
install_transmission_daemon_mac () {
# Install Xcode Command-line Tools
wget -O CLITools.dmg http://adcdownload.apple.com/Developer_Tools/command_line_tools_os_x_10.9_for_xcode__late_july_2014/command_line_tools_for_os_x_mavericks_late_july_2014.dmg
hdiutil attach CLITools.dmg
echo "
On your Mac, please now install the Xcode Command-line Tools. The disk image has been mounted. You can find it using Finder.

Once installed successfully, please hit [ENTER]:	">&2
read finished_xcode_install

echo "You will now have to accept the license agreement for Xcode before you can continue.
" >&2
sleep 3
xcodebuild -license

wget -O MacPortsVersion.html http://www.macports.org/install.php
macports_version_number=$(echo $(cat MacPortsVersion.html | grep "MacPorts version " | cut -d '>' -f 2- | cut -d ' ' -f 3))
rm MacPortsVersion.html
macports_latest_url="https://distfiles.macports.org/MacPorts/MacPorts-$macports_version_number.tar.gz"
wget -O MacPortsSource.tar.gz $macports_latest_url
tar -xvf MacPortsSource.tar.gz && rm MacPortsSource.tar.gz
cd MacPorts-*
./configure && make && sudo make install



}

# Installer script for each program
install () {
	case "$1" in
	transmission_daemon)
		if [[ $transmission_daemon ]]; then
		add-apt-repository -y ppa:transmissionbt/ppa
		apt-get update
		apt-get install transmission-common transmission-daemon transmission-cli
		apt-get -f install
		fi
	;;
	handbrakecli_mac)
		if [[ $handbrakecli ]]; then

		fi
	;;
	handbrakecli_linux)
		if [[ $handbrakecli ]]; then
		add-apt-repository -y ppa:stebbins/handbrake-releases
		apt-get update
		apt-get install handbrake-cli
		apt-get -f install
		fi
	;;
	openssh_server)
		if [[ $openssh ]]; then
		apt-get install openssh-server
		apt-get -f install
		fi
	;;
	duckdns)
		if [[ $duckdns ]]; then
		echo "
Do you have a dynamic address for duckdns.org? [y/n]" >&2
		read answer
		if [[ "$(echo $answer | cut -c 1)" == "y" || "$(echo $answer | cut -c 1)" == "Y" ]]; then
			if [[ -d "/usr/local/bin/duckdns" ]]; then
				rm -rf "/usr/local/bin/duckdns"
				mkdir "/usr/local/bin/duckdns"
			else
				mkdir "/usr/local/bin/duckdns"
			fi
			touch /usr/local/bin/duckdns/duck.sh
			chmod +x /usr/local/bin/duckdns/duck.sh
			echo "
What is your dynamic address for duckdns.org? e.g. for someaddress.duckdns.org type someaddress in below and then hit [ENTER]" >&2
			read dynamicaddress
			echo "
Visit duckdns.org and sign in with your login. On the home screen to the website, there will now be a token shown.
The token is a long sequence of letters, numbers, and hyphons. Copy this and paste it below:

What is your token for duckdns.org?" >&2
			read token
			duckdns_command="echo url=\"https://www.duckdns.org/update?domains=$dynamicaddress&token=$token&ip=\" | curl -k -o /usr/local/bin/duckdns/duck.log -K -"
			echo $duckdns_command >> "/usr/local/bin/duckdns/duck.sh"
			if [[ "$(crontab -u $username_current -l | grep duck.sh)" == "" ]]; then
				line="*/5 * * * * /usr/local/bin/duckdns/duck.sh >/dev/null 2>&1"
				(crontab -u $username_current -l; echo "$line" ) | crontab -u $username_current -
			fi
			/usr/local/bin/duckdns/duck.sh
			if [[ "$(cat /usr/local/bin/duckdns/duck.log)" == "OK" ]]; then echo "DuckDNS installed successfully. Please continue."; else echo "DuckDNS has not been installed correctly, please seek advice on installation from https://www.duckdns.org" >&2; fi
		fi
		
		fi
	;;
	plexmediaserver_mac)
		if [[ $pms ]]; then
		plexmediaserver_version=0.9.9.14.531-7eef8c6
		wget -O PlexMediaServer.zip http://downloads.plexapp.com/plex-media-server/$plexmediaserver_version/PlexMediaServer-$plexmediaserver_version-OSX.zip
		tar -xvf PlexMediaServer.zip
		rm PlexMediaServer.zip
		rsync --delete-before Plex\ Media\ Server.app /Applications/Plex\ Media\ Server.app
		spctl --add --label "Plex_Media_Server" /Applications/Plex\ Media\ Server.app
		spctl --enable --label "Plex_Media_Server"
		fi
	;;
	plexmediaserver_linux)
		if [[ $pms ]]; then
		
		fi
	;;
	plexhometheater)
		if [[ $pht ]]; then
		
		fi
	;;
	filebot_mac)
		if [[ $filebot ]]; then
			wget -O filebot.html http://www.filebot.net
			filebot_version=$(cat filebot.html | grep ".app" | awk -F 'type=app' '{print $2}' | awk -F '_' '{print $NF}' | awk -F '.app' '{print $1}' | tail -n 1)
			rm filebot.html
			filebot_url="http://sourceforge.net/projects/filebot/files/filebot/FileBot_$filebot_version""/FileBot_$filebot_version"".app.tar.gz/download"
			wget -O filebot.app.tar.gz $filebot_url
			tar -xvf filebot.app.tar.gz
			rm filebot.app.tar.gz
		fi
	;;
	filebot_linux)
		if [[ $filebot ]]; then
			wget -O filebot.html http://www.filebot.net
			filebot_version=$(cat filebot.html | grep deb | awk -F 'amd64' '{print $(NF-1)}' | awk -F '_' '{print $(NF-1)}')
			rm filebot.html
			filebot_url="http://sourceforge.net/projects/filebot/files/filebot/FileBot_$filebot_version""/filebot_$filebot_version""_amd64.deb/download"
			wget -O filebot.deb $filebot_url
			dpkg -i filebot.deb
			apt-get -f -y install
			rm filebot.deb
		fi
	;;
	makemkv_mac)
		if [[ $makemkv ]]; then
		
		fi
	;;
	makemkv_linux)
		if [[ $makemkv ]]; then
		
		fi
	;;
	avahi_daemon)
		if [[ $avahi ]]; then
		apt-get install avahi-daemon
		fi
	;;
	esac
}

##
##	SCRIPT
##

username_current=$(basename $HOME)

sudo su

# Checks the operating system being used to determine which script to run
check_os

# Warns the user of any issues, known constraints of using their OS
warning_message

# Installer for each OS
if [[ "$OS" == "Mac" ]]; then
	install handbrakecli_mac
	install filebot_mac
	install plexmediaserver_mac
	install duckdns
	echo "

To finish the installation, please go to System Preferences and change the following settings:

Security & Privacy	-->	General	-->	Turn allowed apps to Anywhere (may require unlocking via bottom left corner of System Preferences)
Sharing --> Remote Login (switch on)

" >&2
elif [[ "$OS" == "Linux" ]]; then
	install handbrakecli_linux
	install filebot_linux
	install plexmediaserver_linux
	install transmission_daemon
	install duckdns
	install avahi_daemon
	install openssh_server
fi