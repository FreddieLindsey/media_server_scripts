#!/bin/bash

script="$0"
makemkv_command="$1"
filebot_command="$2"
filebot_format="$3"
ripping_directory="$4"
output_directory="$5"
disc_eject="$6"

echo "
Script:	\"$0\"
MakeMKV command:	\"$1\"
Filebot command:	\"$2\"
Filebot format:	\"$3\"
output_directory:	\"$4\"
" >&2

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
if [[ ! -d "$ripping_directory" ]]; then mkdir "$ripping_directory"; fi
ripping_command="$makemkv_command \"$ripping_directory\""
echo "$ripping_command"
eval "$ripping_command"
sleep 5
eval "$disc_eject"

# Get biggest file from folder
biggest_file "$ripping_directory"
mv "$biggest_file_path" "$ripping_directory.$biggest_file_ext"

# Delete folder
rm -rf "$ripping_directory"

# Rename biggest file with filebot
echo "$filebot_command \"$output_directory/$filebot_format\"\"$ripping_directory.$biggest_file_ext\"" >&2
eval "$filebot_command \"$output_directory/$filebot_format\" \"$ripping_directory.$biggest_file_ext\"" 