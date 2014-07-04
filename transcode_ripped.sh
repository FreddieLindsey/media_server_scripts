#!/bin/bash


# Get pixel width of file
# mediainfo $file | grep "Width" | sed 's/^.*\(:\)//' | sed 's/\(pixels\).*//' | sed 's/\ //'

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

script_already_running () {
grep_output=$(ps -efa | grep "HandBrakeCLI -i $HOME/Movies/Discs/" | grep -v 'grep ')
if [ grep_output == "" ]; then
	script_already_running=true
	echo "
Script is already running, will not continue.
	" >&2
else
	script_already_running=false
	echo "
Script is not already running, will proceed.
	" >&2
fi
}

rename_folder_with_filebot () { # $1 is the directory where the files are, $2 is the database to use (thetvdb or themoviedb are recommended).
files_to_rename=$1/*
for video_file in $files_to_rename
do
	echo "
Processing "$(basename "$video_file")" with filebot...
"
	filebot_output=$( echo $(filebot -rename -non-strict --db $2 --format "{n} ({y}) ({sdhd} {resolution})" "$video_file" | cut -d'[' -f 3 ) | cut -d']' -f 1)
	
	
	echo ""$(basename "$video_file")" renamed to "$(basename "$filebot_output")"
	" >&2
	
done
}

#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#-----SCRIPT START---------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#

script_already_running

rename_folder_with_filebot "$HOME/Movies/Discs" "themoviedb"