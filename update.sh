#!/bin/bash

script="$0"
if [[ "$(echo "/$(ls -ld $0 | cut -d '/' -f 2-)" | grep -)" != "" ]]; then
	script=$(echo "/$(ls -ld $0 | cut -d '/' -f 2-)" | grep - | cut -d '>' -f 2- | cut -c 2-)
fi
script_directory=$(echo `dirname $script`)
user_current=$(whoami)

# Script must have an argument or it will fail
if [[ -z "$1" ]]; then echo "
Please ensure you argument a git directory to the script.

i.e. run `gitupdate /usr/local/media_server` if the git repository you want to update has the root directory /usr/local/media_server
" >&2 && exit; fi

# Find the branch of the git repository that is being used.
git_url="$(git -C "$script_directory" config -l | grep "remote.origin.url" | awk -F "github.com" '{print $2}')"
git_repository="$(git -C "$script_directory" show-branch --list | grep "*" | awk -F '[' '{print $2}' | awk -F ']' '{print $1}')"

# Check the operating system
if [[ "$(uname)" == "Darwin" ]]; then
	OS="Mac"
	sudo=false
elif [[ "$(uname)" == "Linux" ]]; then
	OS="Linux"
	sudo=true
fi

# Check if the directory that the user has asked to be updated is the same one as the scripts are currently in
if [[ "$script_directory" != "$1" ]]; then
	if [[ -d "$1" ]]; then
		owner="$(ls -l "$(dirname "$1")" | grep "$(basename "$1")" | awk -F ' ' '{print $3}')"
		if [[ "$owner" != "$user_current" ]]; then sudo chown -R "$user_current" "$1"; fi
		if [[ "$(du "$1" | awk -F ' ' '{print $1}' | tail -n 1)" == "0" ]]; then files=false; else files=true; fi
	else
		make_directory="$(mkdir "$1")"
		if [[ "$make_directory" == "mkdir: $1: Permission denied" ]]; then
			echo "
The directory couldn't be made as you don't have the necessary permissions.

Would you like to forcibly try to make the directory? [y/n]" >&2
			read $retry_sudo
			if [[ "$(echo $retry_sudo | cut -c 1)" == "y" || "$(echo $retry_sudo | cut -c 1)" == "Y" ]]; then 
				sudo mkdir "$1" && sudo chown -R "$user_current" "$1"
			elif [[ "$(echo $retry_sudo | cut -c 1)" == "n" || "$(echo $retry_sudo | cut -c 1)" == "N" ]]
				echo "Since the directory \"$1\" could not be created, I will use the original directory, \"$script_directory\" for the rest of the update procedure."
				directory_to_use="$script_directory"
			fi
		fi 
	fi
	
	if [[ $files ]]; then
		# Check to see if the files present are any version of the repository we want to clone/update.
		old_git_url="$(git -C "$1" config -l | grep "remote.origin.url" | awk -F "github.com" '{print $2}')"
		old_git_repository="$(git -C "$1" show-branch --list | grep "*" | awk -F '[' '{print $2}' | awk -F ']' '{print $1}')"
		if [[ "$git_url" == "$old_git_url" && "$git_repository" == "$old_git_repository" ]]; then
			up_to_date="$(git -C "$1" pull origin | grep "Already up-to-date.")"
			if [[ "$up_to_date" == "Already up-to-date." ]]; then
				echo "
The git repository at \"$1\" is already the newest available version. It is identical to the git repository at \"$script_directory\".

Would you like to reinstall the components in \"$1\" rather than in \"$script_directory\"? (i.e. move your working directory)"
				read reinstall
					if [[ "$(echo $reinstall | cut -c 1)" == "y" || "$(echo $reinstall | cut -c 1)" == "Y" ]]; then
						echo "
Reinstalling..." >&2
						eval "$1/install.sh"
					fi
			fi
		fi
	else
		git_done="$(git clone -b "$git_repository" https://www.github.com$git_url "$1" | tail -n 1)"
		if [[ "$git_done" == "Checking connectivity... done." ]]; then rm -rf "$script_directory"; fi
	fi
elif [[ "$script_directory" == "$1" ]]; then
	up_to_date="$(git -C "$1" pull origin | grep "Already up-to-date.")"
		if [[ "$up_to_date" == "Already up-to-date." ]]; then
			echo "
The git repository at \"$1\" is already the newest available version." >&2
		elif [[ "$up_to_date" == "" ]]; then
			echo "
The git repository at \"$1\" has been updated. It is recommended that you reinstall the scripts with the newest version to maintain compatibility."
		fi
fi

# Install over the old install if necessary
if [[ -z "$up_to_date" || "$up_to_date" == "" ]]; then
echo "
Now installing updated script" >&2
eval "$1/install.sh"
else
	echo "
The repository was already up to date, therefore there isn't an explicit need to overwrite the previous install.

Would you like to do a fresh install with new settings? [y/n]" >&2
read reinstall
	if [[ "$(echo $reinstall | cut -c 1)" == "y" || "$(echo $reinstall | cut -c 1)" == "Y" ]]; then
		echo "
Reinstalling..." >&2
		eval "$1/install.sh"
	fi
fi
