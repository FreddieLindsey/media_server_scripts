#!/bin/bash

#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#-----SCRIPT CONFIG--------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#

# Script must have an argument or it will fail
if [[ -z "$2" ]]; then echo "
Please add arguments before using this script.
" >&2 && exit 1; fi

script="$0"
if [[ "$(echo "/$(ls -ld $0 | cut -d '/' -f 2-)" | grep -)" != "" ]]; then
	script=$(echo "/$(ls -ld $0 | cut -d '/' -f 2-)" | grep - | cut -d '>' -f 2- | cut -c 2-)
fi
script_directory=$(echo `dirname $script`)
movie_or_tv="$1"
name_of_file="$2"

configfile="$script_directory/media_server.cfg"
if [[ -f "$configfile" ]]; then echo "
Found config file:		$configfile
" >&2 && source "$configfile"; else echo "
Could not find config file. Are all the relevant scripts and files in the right directory?
" >&2 && exit 1; fi

#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#-----FUNCTIONS------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#

### Checks the OS being used
check_os_disc_inserted () {
	if [ "$(uname)" = "Darwin" ]; then
		OS="Mac"
		disc_inserted=$(drutil status | grep "Type" | grep -v "No Media Inserted")
	elif [ "$(uname)" = "Linux" ]; then
		OS="Linux"
		disc_inserted=$(df -H | grep "/dev/sr")
	else
		echo "Your Operating System is not supported. Please request support via GitHub. If you feel there is an issue, please post it on GitHub."
		exit
	fi
	
	# If disc not inserted, kill.
	if [[ "$disc_inserted" == "" ]]; then
		echo "There is no disc inserted. Will now quit.
		" >&2
		exit 1
	fi

}

# Rips the disc in the drive to the folder name specified in argument 1 inside the set ripping location 
makemkv_rip () {
	# Set the location of makemkvcon according to the OS in use.
	if [ "$OS" = "Mac" ]; then
		makemkvcon="$makemkvcon_mac/makemkvcon"
		filebot="$filebot_location/filebot"
	else
		makemkvcon="makemkvcon"
		filebot="filebot"
	fi
	
	if [[ ! -d "$ripping_loc" ]]; then
		mkdir "$ripping_loc"
	fi
	if [[ -d "$ripping_loc/$1" ]]; then
		rm -rf "$ripping_loc/$1"
		mkdir "$ripping_loc/$1"
	else
		mkdir "$ripping_loc/$1"
	fi
	
	makemkv_command="$makemkvcon mkv disc:0 all --minlength=3600"
	filebot_command="$filebot -rename -non-strict --conflict override --db themoviedb --format "
	filebot_format="$filebot_format_ripped_disc"
	final_output="$transcoding_movie_loc/$name_of_file"
	nohup_command="$script_directory/.ripping.sh \"$makemkv_command\" \"$filebot_command\" \"$filebot_format\" \"$final_output\""
	nohup $nohup_command
}

# Checks if makemkvcon is already running, and if so cancels the script
makemkv_running () {
	makemkv_state=`ps -efa | grep makemkvcon | grep -v 'grep '`

	if [ -n "$makemkv_state" ]; then
		echo "MakeMKV is already running, so script will stop.
		" >&2
		exit 1
	else
		echo "MakeMKV is not running, I will therefore continue.
		" >&2
	fi
}

#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#-----SCRIPT START---------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#

# Check OS type
check_os_disc_inserted

# Check if MakeMKV is already running and if so cancel script
makemkv_running

# Rip the disc with the name given
makemkv_rip "$name_of_file"