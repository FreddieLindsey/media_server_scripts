#!/bin/bash

cd $HOME

wget -O plex.deb http://downloads.plexapp.com/plex-media-server/0.9.9.12.504-3e7f93c/plexmediaserver_0.9.9.12.504-3e7f93c_amd64.deb

sudo dpkg -i plex.deb

rm plex.deb