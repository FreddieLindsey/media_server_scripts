#!/bin/bash

script=$0
makemkv_command=$1
filebot_command=$2
filebot_format=$3
output_directory=$4

##
##	FUNCTIONS
##

biggest_file () {
directory="$1"

cd "$directory"
biggest_file_name=$(du -s * | sort -n | tail -n 1 | cut -d$'\t' -f 2)
cd

biggest_file_ext="${biggest_file_name##*.}"
biggest_file_path="$1/$biggest_file_name"
}

##
##	SCRIPT
##

# Rip disc and eject
eval "$makemkv_command \"$output_directory\""
sleep 5
drutil eject

# Get biggest file from folder
biggest_file "$output_directory"
mv "$biggest_file_path" "$output_directory.$biggest_file_ext"

# Delete folder
rm -rf "$output_directory"

# Rename biggest file with filebot
eval "$filebot_command \"$filebot_format\" \"$output_directory.$biggest_file_ext\"" 