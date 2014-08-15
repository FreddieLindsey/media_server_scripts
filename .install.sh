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
ln -sf "/usr/local/media_server/rip_discs.sh" /usr/local/bin/discripper
ln -sf "/usr/local/media_server/plextranscoder.sh" /usr/local/bin/plext
ln -sf "/usr/local/media_server/transmission_finish.sh" /usr/local/bin/transmissionf
}

# Installer script for each program
installer_script () {
	case "$1" in
	homebrew)
		if [[ $homebrew ]]; then
		echo "
		Homebrew is installing..." >&2
		curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install | grep -v "wait_for_user if STDIN.tty?" >homebrew.rb
		sudo su $username_current -c 'ruby homebrew.rb' >/dev/null 2>&1
		rm homebrew.rb
		echo "
		Homebrew has been successfully installed." >&2
		fi
	;;
	wget)
		if [[ $wget ]]; then
		echo "
		wget is installing..." >&2
		sudo su $username_current -c 'brew update && brew install wget' >/dev/null 2>&1
		echo "
		wget has been successfully installed." >&2
		fi
	;;
	jre)
		if [[ $java ]]; then
		echo "
		Java Runtime Environment is installing..." >&2
		java_image_location=$(hdiutil attach "$script_directory/.software/runtime_environment.dmg" | grep /Volumes/ | awk -F $'\t' '{print $NF}')
		java_image_raw=$(hdiutil attach "$script_directory/.software/runtime_environment.dmg" | grep /Volumes/ | awk -F $'\t' '{print $1}')
		installer -pkg "$java_image_location"/*.pkg -target /
		diskutil unmountDisk $java_image_raw >/dev/null 2>&1
		echo "
		Java Runtime Environment has been successfully installed." >&2
		fi
	;;
	transmission_daemon_mac)
		if [[ $transmission_daemon ]]; then
		echo "
		transmission-daemon is installing..." >&2
		sudo su $username_current -c 'brew update && brew install transmission' >/dev/null 2>&1
		echo "
		transmission-daemon has been installed successfully.
		" >&2
		fi
	;;
	transmission_daemon_linux)
		if [[ $transmission_daemon ]]; then
		echo "
		transmission-daemon is installing..." >&2
		add-apt-repository -y ppa:transmissionbt/ppa >/dev/null 2>&1
		apt-get update >/dev/null 2>&1
		apt-get -y install transmission-common transmission-daemon transmission-cli >/dev/null 2>&1
		apt-get -f install >/dev/null 2>&1
		echo "
		transmission-daemon has been installed successfully.
		" >&2
		fi
	;;
	mkvtoolnix_mac)
		if [[ $mkvtoolnix ]]; then
		echo "
		MKVtoolnix is installing..." >&2
		brew update >/dev/null 2>&1
		brew install mkvtoolnix >/dev/null 2>&1
		echo "
		MKVtoolnix has been installed successfully
		" >&2
		fi
	;;
	mkvtoolnix_linux)
		if [[ $mkvtoolnix ]]; then
		echo "
		MKVtoolnix is installing..." >&2
		apt-get update >/dev/null 2>&1
		apt-get -y install mkvtoolnix >/dev/null 2>&1
		echo "
		MKVtoolnix has been installed successfully
		" >&2
		fi
	;;
	handbrakecli_mac)
		if [[ $handbrakecli ]]; then
		echo "
		HandBrakeCLI is installing..." >&2
		wget -O HandBrakeCLI.dmg http://sourceforge.net/projects/handbrake/files/0.9.9/HandBrake-0.9.9-MacOSX.6_CLI_x86_64.dmg/download >/dev/null 2>&1
		handbrake_image_location=$(hdiutil attach HandBrakeCLI.dmg | grep /Volumes/ | awk -F $'\t' '{print $NF}')
		handbrake_image_raw=$(hdiutil attach HandBrakeCLI.dmg | grep /Volumes/ | awk -F $'\t' '{print $1}')
		cp $handbrake_image_location/HandBrakeCLI /usr/local/bin/
		diskutil unmountDisk $handbrake_image_raw >/dev/null 2>&1
		rm HandBrakeCLI.dmg
		echo "
		HandBrakeCLI has been installed successfully.
		" >&2
		fi
	;;
	handbrakecli_linux)
		if [[ $handbrakecli ]]; then
		echo "
		HandBrakeCLI is installing..." >&2
		apt-get update >/dev/null 2>&1
		apt-get -y install handbrake-cli >/dev/null 2>&1
		apt-get -f install >/dev/null 2>&1
		echo "
		HandBrakeCLI has been installed successfully.
		" >&2
		fi
	;;
	openssh_server)
		if [[ $openssh ]]; then
		echo "
		openssh-server is installing..." >&2
		apt-get -y install openssh-server >/dev/null 2>&1
		apt-get -f install >/dev/null 2>&1
		echo "
		openssh-server has been installed successfully." >&2
		fi
	;;
	duckdns)
		if [[ $duckdns ]]; then
		echo "
		DuckDNS is installing..." >&2
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
			touch /usr/local/bin/duckdns/duck.log
			chmod +x /usr/local/bin/duckdns/duck.sh
			chown -R $username_current /usr/local/bin/duckdns
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
		
		fi
	;;
	plexmediaserver_mac)
		if [[ $pms ]]; then
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
		fi
	;;
	plexmediaserver_linux)
		if [[ $pms ]]; then
		echo "
		Plex Media Server is installing..." >&2
		add-apt-repository -y "deb http://plex.r.worldssl.net/PlexMediaServer/ubuntu-repo lucid main"
		# wget -O plex_pub_key.pub http://plexapp.com/plex_pub_key.pub
		# apt-key add plex_pub_key.pub
		# rm plex_pub_key.pub
		apt-get update >/dev/null 2>&1
		apt-get -y install plexmediaserver --force-yes # Currently can't get key, so must use force yes command
		apt-get -f install
		ip_address="$(ifconfig | grep "Bcast" | grep "inet" | cut -d ":" -f 2 | cut -d ' ' -f 1)"
		echo "
		Plex Media Server has now been installed.
		
		
You can now manage your Plex Media Server at the following address:

http://localhost:32400/web/index.html	(from the computer itself)
http://$ip_address:32400/web/index.html	(from any other computer on the network)


" >&2
		fi
	;;
	plexhometheater_mac)
		if [[ $pht ]]; then
		echo "
		
		
Please understand that running Plex Home Theater on the same machine as the server is NOT recommended. All resources should be given to the server.

Roku sell extremely cheap Plex clients. Roku's Roku 3 is the best solution at around £70/\$100.

Given this, do you still want to install it? [y/n]"
		read plexht_answer
		if [[ "$(echo $plexht_answer | cut -c 1)" == "y" || "$(echo $plexht_answer | cut -c 1)" == "Y" ]]; then
		echo "
		Plex Home Theater is installing..." >&2
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
		fi
	;;
	plexhometheater_linux)
		if [[ $pht ]]; then
		echo "
		
		
Please understand that running Plex Home Theater on the same machine as the server is NOT recommended. All resources should be given to the server.

Roku sell extremely cheap Plex clients. Roku's Roku 3 is the best solution at around £70/\$100.

Given this, do you still want to install it? [y/n]"
		read plexht_answer
		if [[ "$(echo $plexht_answer | cut -c 1)" == "y" || "$(echo $plexht_answer | cut -c 1)" == "Y" ]]; then
		echo "
		Plex Home Theater is installing..." >&2
		add-apt-repository -y ppa:plexapp/plexht >/dev/null 2>&1
		add-apt-repository -y ppa:pulse-eight/libcec >/dev/null 2>&1
		apt-get update >/dev/null 2>&1
		apt-get -y install plexhometheater >/dev/null 2>&1
		echo "
		Plex Home Theater has now been installed." >&2
		fi
		fi
	;;
	filebot_mac)
		if [[ $filebot ]]; then
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
		fi
	;;
	filebot_linux)
		if [[ $filebot ]]; then
		echo "
		FileBot is installing..." >&2
		wget -O filebot.html http://www.filebot.net >/dev/null 2>&1
		filebot_version=$(cat filebot.html | grep deb | awk -F 'amd64' '{print $(NF-1)}' | awk -F '_' '{print $(NF-1)}')
		rm filebot.html
		filebot_url="http://sourceforge.net/projects/filebot/files/filebot/FileBot_$filebot_version""/filebot_$filebot_version""_amd64.deb/download" >/dev/null 2>&1
		wget -O filebot.deb $filebot_url >/dev/null 2>&1
		dpkg -i filebot.deb >/dev/null 2>&1
		apt-get -f -y install >/dev/null 2>&1
		rm filebot.deb >/dev/null 2>&1
		echo "
		FileBot has been installed successfully.
		" >&2
		fi
	;;
	makemkv_mac)
		if [[ $makemkv ]]; then
		echo "
		MakeMKV is installing...
When prompted, please agree to the license agreement." >&2
		wget -O makemkv.html http://www.makemkv.com/download >/dev/null 2>&1
		makemkv_version=$(cat makemkv.html | grep 'MakeMKV v' | awk -F 'MakeMKV v' '{print $2}' | cut -d ' ' -f 1 | head -n 1)
		rm makemkv.html
		makemkv_url="http://www.makemkv.com/download/makemkv_v$makemkv_version""_osx.dmg"
		wget -O makemkv.dmg $makemkv_url >/dev/null 2>&1
		makemkv_image_location=$(hdiutil attach makemkv.dmg | grep /Volumes/ | awk -F $'\t' '{print $NF}')
		makemkv_image_raw=$(hdiutil attach makemkv.dmg | grep /Volumes/ | awk -F $'\t' '{print $1}')
		cp -R $makemkv_image_location/MakeMKV.app /Applications/
		installer -pkg "$makemkv_image_location"/daspi* -target / >/dev/null 2>&1
		diskutil unmountDisk $makemkv_image_raw >/dev/null 2>&1
		rm makemkv.dmg
		echo "
		MakeMKV has been installed successfully.
		" >&2
		fi
	;;
	makemkv_linux)
		if [[ $makemkv ]]; then
		echo "
		MakeMKV is installing..." >&2
		echo "
Installing dependencies..." >&2
		apt-get -y install build-essential pkg-config libc6-dev libssl-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev libqt4-dev >/dev/null 2>&1
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
		fi
	;;
	avahi_daemon)
		if [[ $avahi ]]; then
		apt-get -y install avahi-daemon >/dev/null 2>&1
		apt-get -f install >/dev/null 2>&1
		fi
	;;
	ssh_daemon)
		if [[ $openssh ]]; then
		sudo systemsetup -setremotelogin on >/dev/null 2>&1
		echo "
		Remote Login (ssh) has been switched on.
		" >&2
		else
		sudo systemsetup -setremotelogin off >/dev/null 2>&1
		echo "
		Remote Login (ssh) has been switched off.
		" >&2
		fi
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
	installer_script homebrew
	installer_script wget
	installer_script makemkv_mac
	installer_script mkvtoolnix_mac
	installer_script handbrakecli_mac
	installer_script filebot_mac
	installer_script jre
	installer_script java_runtime_environment
	installer_script plexmediaserver_mac
	installer_script plexhometheater_mac
	installer_script transmission_daemon_mac
	installer_script duckdns
	installer_script ssh_daemon
	echo "

The installation has finished. Please enjoy your server! Download and watch responsibly!

" >&2
elif [[ "$OS" == "Linux" ]]; then
	installer_script makemkv_linux
	installer_script mkvtoolnix_linux
	installer_script handbrakecli_linux
	installer_script filebot_linux
	installer_script plexmediaserver_linux
	installer_script plexhometheater_linux
	installer_script transmission_daemon_linux
	installer_script duckdns
	installer_script avahi_daemon
	installer_script openssh_server
	echo "

The installation has finished. Please enjoy your server! Download and watch responsibly!

You may have to update the permissions of your media directories by running the following commands on them:
\`sudo chown $username_current:plex -R [YOUR MEDIA DIRECTORY HERE]\`
\`sudo chmod 770 -R [YOUR MEDIA DIRECTORY HERE]\`

To update and upgrade your system, please run the following command regularly:

\`sudo apt-get update && sudo apt-get -y upgrade\` 

" >&2
fi