#!/bin/bash

##
##	User-configurable Variables
##

host="$1"
port=$2
user="$3"
pass="$4"
torrent_dir="$5"

list_torrents=$(transmission-remote $host:$port --auth=$user:$pass -l)

echo "
Here is the list of torrents:

$list_torrents

Which torrent would you like to use?" >&2
read torrent_no

name_of_torrent=$(transmission-remote $host:$port --auth=$user:$pass -t $torrent_no -i | grep "Name:" | cut -c 9-)
files=$(transmission-remote $host:$port --auth=$user:$pass -t $torrent_no -f | tail -n +3 | cut -c 35-)

if [[ -d "$torrent_dir$name_of_torrent/BDMV" ]]; then
	torrent_type="Blu-ray"
elif [[ -d "$torrent_dir$name_of_torrent/Video_TS" ]]; then
	torrent_type="DVD"
fi

if [[ -z "$torrent_type" ]]; then

	i_IFS=$IFS
	IFS=$'\n' read -rd '' -a file_array <<<"$files"
	IFS=$i_IFS

	echo "
Here is the list of files for torrent no. $torrent_no:

Total size of torrent is $(stat -c%s \"$torrent_dir$name_of_torrent\")
" >&2

	start=0
	((end=${#file_array[@]}-1))
	for i in $(eval echo "{$start..$end}")
	do
		((no_of_file=$i+1))
		echo "$no_of_file:	${file_array[i]}" >&2
	done
else
		echo "
Torrent with ID $torrent_no and name $name_of_torrent is a $torrent_type" >&2
fi