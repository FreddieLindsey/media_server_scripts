#!/bin/bash

script=$0
cd `dirname $script`
script_directory=$(pwd -P)

cd $HOME

sudo add-apt-repository ppa:stebbins/handbrake-releases

sudo apt-get -y --fix-missing install pkg-config libc6-dev libssl-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev libqt4-dev libgif4 openjdk-7-jre openjdk-7-jre-headless handbrake-cli avahi-daemon

# echo "
# Now installing MakeMKV...
# " >&2

sudo $script_directory/install_makemkv_ubuntu.sh | tee /dev/tty

# echo "
# MakeMKV has been installed...
echo "
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

Now installing FFmpeg...
" >&2

sudo $script_directory/install_ffmpeg_ubuntu.sh | tee /dev/tty

echo "
FFmpeg has been installed
" >&2