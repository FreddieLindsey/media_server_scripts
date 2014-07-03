#!/bin/bash

script=$0
cd `dirname $script`
script_directory=$(pwd -P)

cd $HOME

echo "
Now installing MakeMKV...
" >&2

sudo $script_directory/install_makemkv_ubuntu.sh | tee /dev/tty

echo "
MakeMKV has been installed...

Now installing Filebot...
" >&2

sudo $script_directory/install_filebot_ubuntu.sh | tee /dev/tty

echo "
Filebot has been installed...

Now installing Plex Media Server...
" >&2

sudo $script_directory/install_plex_ubuntu.sh | tee /dev/tty

echo "
Plex Media Server has been installed
" >&2