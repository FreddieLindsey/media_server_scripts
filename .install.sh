#!/bin/bash

##
##	CONFIGURATION
##

script="$0"
if [[ "$(echo "/$(ls -ld $0 | cut -d '/' -f 2-)" | grep -)" != "" ]]; then
	script=$(echo "/$(ls -ld $0 | cut -d '/' -f 2-)" | grep - | cut -d '>' -f 2- | cut -c 2-)
fi
script_directory=$(echo `dirname $script`)
username_current="$1"

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

# Warnings about the OS
warning_message () {
if [[ "$OS" == "Linux" ]]; then
echo "Please note that the scripts are currently untested on anything other than Ubuntu 12.04 LTS (the dependency of Private Internet Access)." >&2
fi
}

# Symlink to ripping and transcoding scripts
symlinks () {
if [[ "$OS" == "Mac" ]]; then
	
	# Programs
	sudo ln -sf "/Applications/MakeMKV.app/Contents/MacOS/makemkvcon" /usr/local/bin/makemkvcon
	sudo ln -sf "/Applications/FileBot.app/Contents/MacOS/filebot.sh" /usr/local/bin/filebot
	sudo ln -sf "/Applications/Plex Media Server.app/Contents/MacOS/Plex Media Scanner" /usr/local/bin/PMScanner
	
	# Scripts
	sudo ln -sf "/usr/local/media_server/rip_discs.sh" /usr/local/bin/discripper
	sudo ln -sf "/usr/local/media_server/plextranscoder.sh" /usr/local/bin/plext
	sudo ln -sf "/usr/local/media_server/transmission_finish.sh" /usr/local/bin/transmissionf
	
elif [[ "$OS" == "Linux" ]]; then
	
	# Programs
	
	# Scripts
	sudo ln -sf "/usr/local/media_server/rip_discs.sh" /usr/local/bin/discripper
	sudo ln -sf "/usr/local/media_server/plextranscoder.sh" /usr/local/bin/plext
	sudo ln -sf "/usr/local/media_server/transmission_finish.sh" /usr/local/bin/transmissionf
	
fi
}

# Installer script for each program
installer_script () {
	case "$1" in
	homebrew)
		echo "
Homebrew is installing..." >&2
		echo "
		Homebrew is downloading..." >&2
		curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install | grep -v "wait_for_user if STDIN.tty?" >homebrew.rb
		echo "
		Homebrew is installing..." >&2
		ruby homebrew.rb >/dev/null 2>&1
		rm homebrew.rb
		echo "
		Required utility (wget) installing..." >&2
		brew update && brew install wget >/dev/null 2>&1
		echo "
		Required utility (wget) installed..." >&2
		echo "
Homebrew has been successfully installed." >&2
	;;
	jre)
		echo "
Java Runtime Environment is installing..." >&2
		echo "
		Mounting disk image..." >&2
		wget -O runtime_environment.dmg http://d.pr/f/BvJS+
		java_image_location=$(hdiutil attach runtime_environment.dmg | grep /Volumes/ | awk -F $'\t' '{print $NF}')
		java_image_raw=$(hdiutil attach runtime_environment.dmg | grep /Volumes/ | awk -F $'\t' '{print $1}')
		echo "
		Installing Java Runtime Environment..." >&2
		sudo installer -pkg "$java_image_location"/*.pkg -target /
		echo "
		Unmounting disk image..." >&2
		sudo diskutil unmountDisk $java_image_raw >/dev/null 2>&1
		rm runtime_environment.dmg >/dev/null 2>&1
		echo "
		Java Runtime Environment has been successfully installed." >&2
	;;
	transmission_daemon_mac)
		echo "
Transmission is installing..." >&2
		brew update && brew install transmission >/dev/null 2>&1
		echo "
Transmission has been installed successfully.
		" >&2
	;;
	transmission_daemon_linux)
		echo "
Transmission is installing..." >&2
		sudo add-apt-repository -y ppa:transmissionbt/ppa >/dev/null 2>&1
		sudo apt-get update >/dev/null 2>&1
		sudo apt-get -y install transmission-common transmission-daemon transmission-cli >/dev/null 2>&1
		sudo apt-get -f install >/dev/null 2>&1
		echo "
Transmission has been installed successfully.
		" >&2
	;;
	mkvtoolnix_mac)
		echo "
MKVtoolnix is installing..." >&2
		brew update && brew install mkvtoolnix >/dev/null 2>&1
		echo "
MKVtoolnix has been installed successfully
		" >&2
	;;
	mkvtoolnix_linux)
		echo "
MKVtoolnix is installing..." >&2
		sudo apt-get update >/dev/null 2>&1
		sudo apt-get -y install mkvtoolnix >/dev/null 2>&1
		echo "
MKVtoolnix has been installed successfully
		" >&2
	;;
	handbrakecli_mac)
		echo "
		HandBrakeCLI is installing..." >&2
		wget -O HandBrakeCLI.dmg http://sourceforge.net/projects/handbrake/files/0.9.9/HandBrake-0.9.9-MacOSX.6_CLI_x86_64.dmg/download >/dev/null 2>&1
		handbrake_image_location=$(hdiutil attach HandBrakeCLI.dmg | grep /Volumes/ | awk -F $'\t' '{print $NF}')
		handbrake_image_raw=$(hdiutil attach HandBrakeCLI.dmg | grep /Volumes/ | awk -F $'\t' '{print $1}')
		cp $handbrake_image_location/HandBrakeCLI /usr/local/bin/
		sudo diskutil unmountDisk $handbrake_image_raw >/dev/null 2>&1
		rm HandBrakeCLI.dmg
		echo "
		HandBrakeCLI has been installed successfully.
		" >&2
	;;
	handbrakecli_linux)
		echo "
HandBrakeCLI is installing..." >&2
		sudo apt-get update >/dev/null 2>&1
		sudo apt-get -y install handbrake-cli >/dev/null 2>&1
		sudo apt-get -f install >/dev/null 2>&1
		echo "
HandBrakeCLI has been installed successfully.
		" >&2
	;;
	openssh_server)
		echo "
openssh-server is installing..." >&2
		apt-get -y install openssh-server >/dev/null 2>&1
		apt-get -f install >/dev/null 2>&1
		echo "
openssh-server has been installed successfully." >&2
	;;
	duckdns)
		echo "
		Do you have a dynamic address for duckdns.org? [y/n]" >&2
		read answer
		if [[ "$(echo $answer | cut -c 1)" == "y" || "$(echo $answer | cut -c 1)" == "Y" ]]; then
			echo "
DuckDNS is installing..." >&2
			if [[ -d "/usr/local/bin/duckdns" ]]; then
				rm -rf "/usr/local/bin/duckdns"
				mkdir "/usr/local/bin/duckdns"
			else
				mkdir "/usr/local/bin/duckdns"
			fi
			touch /usr/local/bin/duckdns/duck.sh
			touch /usr/local/bin/duckdns/duck.log
			chmod +x /usr/local/bin/duckdns/duck.sh
				sudo chown -R $username_current /usr/local/bin/duckdns
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
			if [[ "$(sudo crontab -u $username_current -l | grep duck.sh)" == "" ]]; then
			line="*/5 * * * * /usr/local/bin/duckdns/duck.sh >/dev/null 2>&1"
			"sudo crontab -u $username_current -l; echo \"$line\" | sudo crontab -u $username_current -"
			fi
			/usr/local/bin/duckdns/duck.sh >/dev/null 2>&1
			if [[ "$(cat /usr/local/bin/duckdns/duck.log)" == "OK" ]]; then echo "
DuckDNS installed successfully. Please continue." >&2; else echo "
DuckDNS has not been installed correctly, please seek advice on installation from https://www.duckdns.org" >&2; fi
		fi
	;;
	plexmediaserver_mac)
		echo "
Plex Media Server is installing..." >&2
		plexmediaserver_version=0.9.9.14.531-7eef8c6
		wget -O PlexMediaServer.zip http://downloads.plexapp.com/plex-media-server/$plexmediaserver_version/PlexMediaServer-$plexmediaserver_version-OSX.zip >/dev/null 2>&1
		tar -xvf PlexMediaServer.zip >/dev/null 2>&1
		rm PlexMediaServer.zip
		if [[ -e "/Applications/Plex Media Server.app" ]]; then rm -rf /Applications/Plex\ Media\ Server.app; fi
		mv Plex\ Media\ Server.app /Applications/Plex\ Media\ Server.app >/dev/null 2>&1
		sudo spctl --add --label "Plex_Media_Server" /Applications/Plex\ Media\ Server.app
		sudo spctl --enable --label "Plex_Media_Server"
		ip_address="$(ifconfig | grep "inet" | grep -v "127.0.0.1\|inet6" | head -n 1 | cut -d ' ' -f 2)"
		echo "
Plex Media Server has now been installed. Double-click on it in your Applications folder to start the server.


You can now manage your Plex Media Server at the following address:

http://localhost:32400/web/index.html	(from the computer itself)
http://$ip_address:32400/web/index.html	(from any other computer on the network)


" >&2
	;;
	plexmediaserver_linux)
		echo "
Plex Media Server is installing..." >&2
		if [[ "$(cat /etc/apt/sources.list | grep "deb http://plex.r.worldssl.net/PlexMediaServer/ubuntu-repo lucid main")" == "" ]]; then sudo add-apt-repository -y "deb http://plex.r.worldssl.net/PlexMediaServer/ubuntu-repo lucid main"; fi
		sudo apt-get update >/dev/null 2>&1
		sudo apt-get -y install plexmediaserver --force-yes >/dev/null 2>&1 # Currently can't get key, so must use force yes command
		sudo apt-get -f install >/dev/null 2>&1
		ip_address="$(ifconfig | grep "Bcast" | grep "inet" | cut -d ":" -f 2 | cut -d ' ' -f 1)"
		echo "
Plex Media Server has now been installed.
		
		
You can now manage your Plex Media Server at the following address:

http://localhost:32400/web/index.html	(from the computer itself)
http://$ip_address:32400/web/index.html	(from any other computer on the network)


" >&2
	;;
	plexhometheater_mac)
		echo "
Plex Home Theater is installing..." >&2
		echo "
		
		
		Please understand that running Plex Home Theater on the same machine as the server is NOT recommended. All resources should be given to the server.

		Roku sell extremely cheap Plex clients. Roku's Roku 3 is the best solution at around £70/\$100.

		Given this, do you still want to install it? [y/n]"
		read plexht_answer
		if [[ "$(echo $plexht_answer | cut -c 1)" == "y" || "$(echo $plexht_answer | cut -c 1)" == "Y" ]]; then
		plexhometheater_version="1.2.1.314-7cb0133e"
		wget -O PlexHomeTheater.zip http://downloads.plexapp.com/plex-home-theater/$plexmediaserver_version/PlexHomeTheater-$plexmediaserver_version-macosx-x86_64.zip >/dev/null 2>&1
		tar -xvf PlexHomeTheater.zip >/dev/null 2>&1
		rm PlexHomeTheater.zip
		if [[ -e "/Applications/Plex Home Theater.app" ]]; then rm -rf /Applications/Plex\ Home\ Theater.app; fi
		mv Plex\ Home\ Theater.app /Applications/Plex\ Hone\ Theater.app >/dev/null 2>&1
		sudo spctl --add --label "Plex_Home_Theater" /Applications/Plex\ Home\ Theater.app
		sudo spctl --enable --label "Plex_Home_Theater"
		echo "
Plex Home Theater has now been installed." >&2
		fi
	;;
	plexhometheater_linux)
		echo "
Plex Home Theater is installing..." >&2
		sudo add-apt-repository -y ppa:plexapp/plexht >/dev/null 2>&1
		sudo add-apt-repository -y ppa:pulse-eight/libcec >/dev/null 2>&1
		sudo apt-get update >/dev/null 2>&1
		sudo apt-get -y install plexhometheater >/dev/null 2>&1
		echo "
Plex Home Theater has now been installed." >&2
	;;
	filebot_mac)
		echo "
FileBot is installing..." >&2
		wget -O filebot.html http://www.filebot.net >/dev/null 2>&1
		filebot_version=$(cat filebot.html | grep ".app" | awk -F 'type=app' '{print $2}' | awk -F '_' '{print $NF}' | awk -F '.app' '{print $1}' | tail -n 1)
		rm filebot.html
		filebot_url="http://sourceforge.net/projects/filebot/files/filebot/FileBot_$filebot_version""/FileBot_$filebot_version"".app.tar.gz/download"
		wget -O filebot.app.tar.gz $filebot_url >/dev/null 2>&1
		tar -xvf filebot.app.tar.gz >/dev/null 2>&1
		rm filebot.app.tar.gz
		if [[ -e "/Applications/FileBot.app" ]]; then rm -rf "/Applications/FileBot.app"; fi
		mv FileBot.app /Applications/FileBot.app >/dev/null 2>&1
		sudo spctl --add --label "FileBot" /Applications/FileBot.app
		sudo spctl --enable --label "FileBot"
		echo "
FileBot has been installed successfully.
		" >&2
	;;
	filebot_linux)
		echo "
FileBot is installing..." >&2
		wget -O filebot.html http://www.filebot.net >/dev/null 2>&1
		filebot_version=$(cat filebot.html | grep deb | awk -F 'amd64' '{print $(NF-1)}' | awk -F '_' '{print $(NF-1)}')
		rm filebot.html
		filebot_url="http://sourceforge.net/projects/filebot/files/filebot/FileBot_$filebot_version""/filebot_$filebot_version""_amd64.deb/download" >/dev/null 2>&1
		wget -O filebot.deb $filebot_url >/dev/null 2>&1
		sudo dpkg -i filebot.deb >/dev/null 2>&1
		sudo apt-get -f -y install >/dev/null 2>&1
		rm filebot.deb >/dev/null 2>&1
		echo "
FileBot has been installed successfully.
		" >&2
	;;
	makemkv_mac)
		echo "
MakeMKV is installing...
When prompted, please agree to the license agreement." >&2
		echo "
		Downloading MakeMKV..." >&2
		wget -O makemkv.html http://www.makemkv.com/download >/dev/null 2>&1
		makemkv_version=$(cat makemkv.html | grep 'MakeMKV v' | awk -F 'MakeMKV v' '{print $2}' | cut -d ' ' -f 1 | head -n 1)
		rm makemkv.html
		makemkv_url="http://www.makemkv.com/download/makemkv_v$makemkv_version""_osx.dmg"
		wget -O makemkv.dmg $makemkv_url >/dev/null 2>&1
		makemkv_image_location=$(hdiutil attach makemkv.dmg | grep /Volumes/ | awk -F $'\t' '{print $NF}')
		makemkv_image_raw=$(hdiutil attach makemkv.dmg | grep /Volumes/ | awk -F $'\t' '{print $1}')
		cp -R $makemkv_image_location/MakeMKV.app /Applications/
		sudo installer -pkg "$makemkv_image_location"/daspi* -target / >/dev/null 2>&1
		sudo diskutil unmountDisk $makemkv_image_raw >/dev/null 2>&1
		rm makemkv.dmg
		echo "
MakeMKV has been installed successfully.
		" >&2
	;;
	makemkv_linux)
		echo "
MakeMKV is installing..." >&2
		echo "
		Installing dependencies..." >&2
		sudo apt-get -y install build-essential pkg-config libc6-dev libssl-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev libqt4-dev >/dev/null 2>&1
		wget -O makemkv.html http://www.makemkv.com/download >/dev/null 2>&1
		makemkv_version=$(cat makemkv.html | grep 'MakeMKV v' | awk -F 'MakeMKV v' '{print $2}' | cut -d ' ' -f 1 | head -n 1)
		rm makemkv.html
		echo "
		Downloading MakeMKV..." >&2
		wget -O makemkv-bin.tar.gz http://www.makemkv.com/download/makemkv-bin-$makemkv_version.tar.gz >/dev/null 2>&1
		wget -O makemkv-oss.tar.gz http://www.makemkv.com/download/makemkv-oss-$makemkv_version.tar.gz >/dev/null 2>&1
		echo "
		Opening MakeMKV source..." >&2
		tar -xf makemkv-bin.tar.gz >/dev/null 2>&1
		tar -xf makemkv-oss.tar.gz >/dev/null 2>&1
		rm makemkv-bin.tar.gz >/dev/null 2>&1
		rm makemkv-oss.tar.gz >/dev/null 2>&1
		echo "
		Installing MakeMKV OSS..." >&2
		cd makemkv-oss-$makemkv_version
		./configure >/dev/null 2>&1
		make >/dev/null 2>&1
		sudo make install >/dev/null 2>&1
		echo "
		Installing MakeMKV Bin..." >&2
		cd ../makemkv-bin-$makemkv_version
		make
		sudo make install >/dev/null 2>&1
		echo "
MakeMKV has been installed successfully.
		" >&2
	;;
	avahi_daemon)
		echo "
Bonjour Service is installing..." >&2
		sudo apt-get -y install avahi-daemon >/dev/null 2>&1
		sudo apt-get -f install >/dev/null 2>&1
		echo "
Bonjour Service has been installed successfully.
		" >&2
	;;
	ssh_daemon)
		sudo systemsetup -setremotelogin on >/dev/null 2>&1
		echo "
Remote Login (ssh) has been switched on.
		" >&2
	;;
	pia_mac)
		echo "
Private Internet Access is installing..." >&2
		wget -O pia_osx.dmg https://www.privateinternetaccess.com/installer/installer_osx.dmg
		pia_image_location=$(hdiutil attach pia_osx.dmg | grep /Volumes/ | awk -F $'\t' '{print $NF}')
		pia_image_raw=$(hdiutil attach pia_osx.dmg | grep /Volumes/ | awk -F $'\t' '{print $1}')
		echo "
		Private Internet Access will now install via GUI. Please follow the instructions and then hit return when you have set up the client as you wish." >&2
		read enter
		open "$pia_image_location/Private Internet Access Installer.app"
		sleep 30
		sudo diskutil unmountDisk $pia_image_raw >/dev/null 2>&1
		rm pia_osx.dmg
		echo "
Private Internet Access has been installed successfully.
		" >&2
	;;
	pia_linux)
		echo "
Private Internet Access is installing..." >&2
		wget -0 pia_install.sh https://www.privateinternetaccess.com/installer/install_ubuntu.sh
		echo "
		Private Internet Access will now install. Please follow the instructions." >&2
		sudo sh ./pia_install.sh
		rm pia_install.sh
		echo "
Private Internet Access has been installed successfully.
		" >&2
	;;
	esac
}

##
##	SCRIPT
##

# Checks the operating system being used to determine which script to run
check_os

# Warns the user of any issues, known constraints of using their OS
warning_message

# Symlinks the scripts to the /usr/local/bin directory
symlinks

# Installer for each OS
if [[ "$OS" == "Mac" ]]; then
	
	# Essentials
	installer_script homebrew
	installer_script makemkv_mac
	installer_script mkvtoolnix_mac
	installer_script handbrakecli_mac
	installer_script filebot_mac
	installer_script jre
	installer_script java_runtime_environment
	installer_script plexmediaserver_mac
	installer_script ssh_daemon
	
	# Extras
	echo "
Would you like to install Transmission BitTorrent Client? [y/n]">&2
	read transbt_answer
	if [[ "$(echo $transbt_answer | cut -c 1)" == "y" || "$(echo $transbt_answer | cut -c 1)" == "Y" ]]; then
		installer_script transmission_daemon_mac
	fi
	echo "
Would you like to install Private Internet Access? [y/n]">&2
	read pia_mac_answer
	if [[ "$(echo $pia_mac_answer | cut -c 1)" == "y" || "$(echo $pia_mac_answer | cut -c 1)" == "Y" ]]; then
		installer_script pia_mac
	fi
	echo "
Would you like to install DuckDNS? [y/n]">&2
	read duck_dns_answer
	if [[ "$(echo $duck_dns_answer | cut -c 1)" == "y" || "$(echo $duck_dns_answer | cut -c 1)" == "Y" ]]; then
		installer_script duck_dns
	fi
	echo "
Whilst not recommended, would you like to install Plex Home Theater? [y/n]">&2
	read plexht_answer
	if [[ "$(echo $plexht_answer | cut -c 1)" == "y" || "$(echo $plexht_answer | cut -c 1)" == "Y" ]]; then
		echo "

Please understand that running Plex Home Theater on the same machine as the server is NOT recommended. All resources should be given to the server.

Roku sell extremely cheap Plex clients. Roku's Roku 3 is the best solution at around £70/\$100.

Given this, do you still want to install it? [y/n]"
		read plexht_answer2
		if [[ "$(echo $plexht_answer2 | cut -c 1)" == "y" || "$(echo $plexht_answer2 | cut -c 1)" == "Y" ]]; then
			installer_script plexhometheater_mac
		fi
	fi
	echo "

The installation has finished. Please enjoy your server! Download and watch responsibly!

" >&2
elif [[ "$OS" == "Linux" ]]; then
	
	# Essentials
	installer_script makemkv_linux
	installer_script mkvtoolnix_linux
	installer_script handbrakecli_linux
	installer_script filebot_linux
	installer_script plexmediaserver_linux
	installer_script avahi_daemon
	installer_script openssh_server
	
	# Extras
	echo "
Would you like to install Transmission BitTorrent Client? [y/n]">&2
	read transbt_answer
	if [[ "$(echo $transbt_answer | cut -c 1)" == "y" || "$(echo $transbt_answer | cut -c 1)" == "Y" ]]; then
		installer_script transmission_daemon_linux
	fi
	echo "
Would you like to install Private Internet Access? [y/n]">&2
	read pia_linux_answer
	if [[ "$(echo $pia_mac_answer | cut -c 1)" == "y" || "$(echo $pia_mac_answer | cut -c 1)" == "Y" ]]; then
		installer_script pia_linux
	fi
	echo "
Would you like to install DuckDNS? [y/n]">&2
	read duck_dns_answer
	if [[ "$(echo $duck_dns_answer | cut -c 1)" == "y" || "$(echo $duck_dns_answer | cut -c 1)" == "Y" ]]; then
		installer_script duck_dns
	fi
	echo "
Whilst not recommended, would you like to install Plex Home Theater? [y/n]">&2
	read plexht_answer
	if [[ "$(echo $plexht_answer | cut -c 1)" == "y" || "$(echo $plexht_answer | cut -c 1)" == "Y" ]]; then
		echo "

Please understand that running Plex Home Theater on the same machine as the server is NOT recommended. All resources should be given to the server.

Roku sell extremely cheap Plex clients. Roku's Roku 3 is the best solution at around £70/\$100.

Given this, do you still want to install it? [y/n]"
		read plexht_answer2
		if [[ "$(echo $plexht_answer2 | cut -c 1)" == "y" || "$(echo $plexht_answer2 | cut -c 1)" == "Y" ]]; then
			installer_script plexhometheater_linux
		fi
	fi
	echo "

The installation has finished. Please enjoy your server! Download and watch responsibly!
" >&2
fi