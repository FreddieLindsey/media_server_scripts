#!/bin/bash

script=$0
cd `dirname $script`
script_directory=$(pwd -P)

cd $HOME

mounted=$(mountpoint -q /media/freddieshoreditch/* && echo true || echo false)

if mounted; then
   $script_directory/rip_discs.sh >&1
fi