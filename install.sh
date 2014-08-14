#!/bin/bash

script="$0"
if [[ "$(echo "/$(ls -ld $0 | cut -d '/' -f 2-)" | grep -)" != "" ]]; then
	script=$(echo "/$(ls -ld $0 | cut -d '/' -f 2-)" | grep - | cut -d '>' -f 2- | cut -c 2-)
fi
script_directory=$(echo `dirname $script`)

username_current=$(basename $HOME)

sudo su root -c "$script_directory/.install.sh $username_current"