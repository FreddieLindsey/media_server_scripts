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

config_file="$script_directory/media_server_config.conf"

#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#-----FUNCTIONS------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#

check_directories () {
# Check the directory exists, in either the specified location, or in the home folder, and if neither are present, creates a new one.
case $1 in
	ripping)
		if [ -d "$ripping_loc" ]; then
			echo "true" >&2
			ripping="$ripping_loc"
		elif [ -d "$HOME$ripping_loc" ]; then
			ripping="$HOME$ripping_loc"
		else
			mkdir "$HOME$ripping_loc"
			ripping="$HOME$ripping_loc"
		fi
	;;
	transcoding)
		if [ -d "$transcoding_loc" ]; then
			transcoding="$transcoding_loc"
		elif [ -d "$HOME$transcoding_loc" ]; then
			transcoding="$HOME$transcoding_loc"
		else
			mkdir "$HOME$transcoding_loc"
			transcoding="$HOME$transcoding_loc"
		fi
	;;
	temp)
		if [ -d "$temp_loc" ]; then
			temp="$temp_loc"
		elif [ -d "$HOME$temp_loc" ]; then
			temp="$HOME$temp_loc"
		else
			mkdir "$HOME$temp_loc"
			temp="$HOME$temp_loc"
		fi
	;;
	output)
		if [ -d "$output_loc" ]; then
			output="$output_loc"
		elif [ -d "$HOME$output_loc" ]; then
			output="$HOME$output_loc"
		else
			mkdir "$output_loc"
			output="$output_loc"
		fi
	;;
esac
}

sanity_check () {

# Check the config file exists, and use it as source
echo "
Checking for configuration file at "$config_file"
" >&2
if [ -f "$config_file" ]; then
	echo "
Using the configuration file found at $config_file with the following parameters" >&2
	source "$config_file"
	
	# Check the directories required exist
	check_directories "ripping"
	check_directories "transcoding"
	check_directories "temp"
	check_directories "output"
	
	echo "
Directories being used for file storage:

	Ripping:	"$ripping"			# Used for saving mkvs from discs
	Transcoding:	"$transcoding"			# Used for transcoding mkvs to formats specified below
	Temporary:	"$temp"			# Temporary storage where files being transcoded are held
	Output:		"$output"			# The final root directory where the files should be saved

Formats for different inputs:

	SD:		"$sd"
	HD 720p:	"$hd_720"
	HD 1080p:	"$hd_1080"

" >&2
else
	echo "A configuration file wasn't found. Script will now exit." >&2
	exit
fi

}

# Checks to see if HandBrake is already transcoding files in the transcoding location.
script_already_running () {
grep_output=$(ps -efa | grep "HandBrakeCLI -i $HOME/Movies/Discs/" | grep -v 'grep ')
if [ "$grep_output" != "" ]; then
	script_already_running=true
	echo "
Script is already running, will not continue.
	" >&2
	exit
else
	script_already_running=false
	echo "
Script is not already running, will proceed.
	" >&2
fi
}

rename_folder_with_filebot () { # $1 is the directory where the files are, $2 is the database to use (thetvdb or themoviedb are recommended).
files_to_rename=$1/*
filebot_names=()
for video_file in $files_to_rename
do
	echo "
Processing "$(basename "$video_file")" with filebot...
"
	filebot_output=$( echo $(filebot -rename -non-strict --db $2 --format "{n} ({y}) ({sdhd} {resolution})" "$video_file")) # | cut -d']' -f -2 ) | cut -d'[' -f 1 )
	new_name=$(echo $filebot_output | echo $(perl -F"]" -wane 'print $F[-2]') | sed 's/^.*\[//' )
	
	echo ""$(basename "$video_file")" renamed to "$(basename "$new_name")"
	" >&2
	
	new_name_underscored=$(echo "$1/$(basename "$new_name")" | tr '_' '%' | tr ' ' '_')
	filebot_names+=("$new_name_underscored")
	
done
}

# Transcodes a given array of files ($1) from a given input folder ($2), using a given temp folder ($3), to a given output folder ($4)
transcode_folder () {
input="$1[@]"
input_folder="$2"
temporary="$3"
output_root="$4"

rm -rf "$temporary" # Clean the temporary directory

input_array=("${!input}")

for i in ${input_array[@]}; do
	input_file=$(echo "$i" | tr '_' ' ' | tr '%' '_')
	echo "
Processing $(basename "$input_file") in $(dirname "$input_file")...
" >&2
done
}

# Transcode a file ($1) using HandBrake, to a given output file ($2), using a given command ($3)
transcode_handbrake () {
	echo "
Will transcode $(basename "$1") to $(basename "$2") using HandBrake...
" >&2
	echo $(nice HandBrakeCLI -i "$1" -o "$2" $3) >&1
	echo "
Finished transcoding $(basename "$1") to $(basename "$2")
" >&2
} 

#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#-----SCRIPT START---------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#

sanity_check

script_already_running

rename_folder_with_filebot "$transcoding" "themoviedb"

transcode_folder filebot_names "$transcoding" "$temp" "$output"