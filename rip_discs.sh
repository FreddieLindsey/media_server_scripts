#!/bin/bash

#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#-----SCRIPT CONFIG--------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#

script=$0
cd `dirname $script`
script_directory=$(pwd -P)

configfile="$script_directory/media_centre_config.conf"

#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#-----FUNCTIONS------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#

### Checks the config file above and ensures the config file being used is clean
get_source () 
{
# Print the location of the config file in use
if [ -e $configfile ]; then
	echo "
Config file found at:			$configfile
	";
else
	echo "
Config file not found, please check the script:		$0
	"
	exit;
fi

# check if the file contains something we don't want
echo "Reading config file...

N.B. Config file is not being checked currently, hence, BECAREFUL! - future releases may change this.
" >&2

source "$configfile"
}

# Send the disc_mount as the input variable to get the name and year out. $1 defines the request, $2 is the disc mounting point or the search term
get_disc_info () {
	case $1 in
	"volume_name") 
		output=$(diskutil info $2 | grep 'Volume Name: ')
		output=$(echo $output | sed 's/^.*\(Volume Name: \)//')
		output=$(echo $output | sed 's/\( \)//') # To remove all spaces from the start and end of the text
		volume_name=$output
	;;
	"disc_kind")
		output=$(drutil status | grep 'Name: ')
		name_output=$(echo $output | sed 's/\(Type: \)//')
		name_output=$(echo $name_output | sed 's/\(Name: \).*//')
		name_output=$(echo $name_output | sed 's/\( \)//') # To remove all spaces from the start and end of the text
		disc_kind=$name_output
		mount_output=$(echo $output | sed 's/^.*\(Name: \)//')
		mount_output=$(echo $mount_output | sed 's/\( \)//') # To remove all spaces from the start and end of the text
		disc_mount=$mount_output
	;;
	"title")
		name=$(echo "$2" | sed 's/\(_\)//')
		title=$(python $get_movie_info "$name" title 2>&1 /dev/null) 
	;;
	"year") 
		year=$(python $get_movie_info "$2" release_date 2>&1 /dev/null)
		year=${year:1:4}
	;;
	esac
}

# Rips the disc in the drive to the folder name specified in argument 1 inside the set ripping location 
makemkv_rip () {
	echo "Starting ripping the disc in the drive to the folder $HOME$ripping_loc/$1...
	"
	mkdir $HOME$ripping_loc/$1
	makemkvoutput=$($makemkvcon mkv disc:0 all --minlength=3600 "$HOME$ripping_loc/$1" | tee /dev/tty)
	echo "Finished ripping the disc in the drive to the folder $HOME$ripping_loc/$1...
	"
	drutil eject
}

# Checks if makemkvcon is already running, and if so cancels the script
makemkv_running () {
	makemkv_state=`ps -efa | grep makemkvcon | grep -v 'grep '`

	if [ -n "$makemkv_state" ]; then
		echo "MakeMKV is already running, but script will continue.
		" >&2
	else
		echo "MakeMKV is not running, I will therefore continue.
		" >&2
	fi
}

# Gets the name of the disc from Disk Utility
disk_utility_name () {

# See if the disc inserted, if there is one, is a Blu-ray or a DVD and print this to the user.
if [ -z "${disc_kind}" ]; then
	exit
else
	if [ $disc_kind = "BD-ROM" ]; then
		echo "The disc inserted is a $disc_kind. Disk Utility will now provide the name for the device at $disc_mount.
		" >&2
	elif [ $disc_kind = "DVD-ROM" ]; then
		echo "The disc inserted is a $disc_kind. Disk Utility will now provide the name for the device at $disc_mount.
		" >&2
	else
		echo "There is no compatible disc inserted, script will now exit." >&2
		exit
	fi
fi

# Get the name of the disc as printed by the OS
echo "Reading disc name...
" >&2
get_disc_info "volume_name" "$disc_mount"
echo "Disc name is $volume_name
" >&2
}

# Checks the name of the disc, and if blank, replaces it with the volume name
check_name () {
if [ "$1" = "()" ]; then
echo "Received empty name. Will now correct with original volume name" >&2
disc_name_year=$2
fi
}

#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#-----SCRIPT START---------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#

# Get the source config file, and clean if necessary
get_source

# Check if MakeMKV is already running and if so cancel script
makemkv_running

# Get the kind and name of the disc currently inserted.
get_disc_info "disc_kind"
disk_utility_name

makemkv_rip "$volume_name"