#!/bin/bash

#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#-----SCRIPT CONFIG--------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#
#--------------------------------------------------------------------------------------------------#

script=$0
cd `dirname $script`
script_directory=$(pwd -P)
movie_or_tv="$1"
name_of_file="$2"

# Script must have two arguments or it will fail
if [[ -z "$2" ]]; then echo "
Please ensure you append a file type and the file location you wish to process to the script.
" >&2 && exit; fi

# Search for and source a config file
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

# Gets the first audio track number which is in the desired language
get_lang () {
input_file="$1"
language_to_find="$2"

# mediainfo must be installed for the script to work

no_tracks=$(mediainfo "$input_file" | grep "Language" | cut -d':' -f 2 | tr -d ' ')
no_video=$(mediainfo "$input_file" | grep "Video" | grep -v "Format" | grep -v "Codec")
no_audio=$(mediainfo "$input_file" | grep "Audio" | grep -v "Format" | grep -v "Codec")

oldIFS=$IFS
IFS=$'\n' 
read -rd '' -a track_array <<<"$no_tracks"
read -rd '' -a video_array <<<"$no_video"
read -rd '' -a audio_array <<<"$no_audio"
IFS=$oldIFS

if [[ ${#audio_array[@]} -gt 1 ]]; then
	starting_track=${#video_array[@]}
	ending_track=$((${#video_array[@]}+${#audio_array[@]}-1))

	for i in $(eval echo {$starting_track..$ending_track})
	do
	    if [[ "${track_array[i]}" == "$language_to_find" ]] ; then
	    	audio_track="$(($i+1-${#video_array[@]}))"
	    fi
	done
else
	audio_track="1"
fi
}

<<COMMENT
# Analyse how many formats and which formats should be used when transcoding
format_output () {

}
COMMENT

# Transcode a file with HandBrakeCLI with the formats specified in argument 2 (1,2 or 1,3 for example) and then rename using Filebot before deleting the original file
transcode_with_handbrake_and_filebot () {
input_file="$1"
basename=$(basename "$1")
filename=${basename%.*}
get_lang "$1" "English"

oldIFS=$IFS
IFS=',' read -rd '' -a format_numbers <<<"$2"
IFS=$oldIFS

for i in "${format_numbers[@]}"
do
	i=$(echo $i | tr -d ' ')
	case "$i" in
	0)
		transcode_settings="$transcode_zer"
	;;
	1)
		transcode_settings="$transcode_one"
	;;
	2)
		transcode_settings="$transcode_two"
	;;
	3)
		transcode_settings="$transcode_thr"
	;;
	esac
	
	if [[ "$i" != "" ]]; then
	output_format="$temp_loc/$filename""_$i.mkv"	
	handbrake_command="$HandBrakeCLI -i \"$1\" -o \"$output_format\" $transcode_settings -a $audio_track"
	echo $handbrake_command >&2
	# eval $handbrake_command 
	fi
done
# rm "$1"

}


##
##	SCRIPT START
##

check_os

if [[ "$movie_or_tv" == "movie" ]]; then
	transcode_with_handbrake_and_filebot "$name_of_file" 1,3
elif [[ "$movie_or_tv" == "tv" ]]; then
	transcode_with_handbrake_and_filebot "$name_of_file" 0,1,,3
fi



<<COMMENTED


handbrake_command_1="$handbrake_location/HandBrakeCLI -i \"$1\" -o \"$file_1st_output\" $handbrake_format_conditions_1"
echo "
Executing...

$handbrake_command_1

" >&2
eval $handbrake_command_1

# Remove the original file and move the encoded version to the output directory

# rm "$1"

# Use filebot to organise the file

filebot_command_1="$filebot_location/filebot -non-strict -rename --conflict override --db themoviedb --format \"$filebot_format_conditions\" --output \"$output_dir\" \"$file_1st_output\""

echo "
Will now execute the command:
$filebot_command_1

" >&2
eval $filebot_command_1
COMMENTED