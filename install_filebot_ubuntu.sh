#!/bin/bash

cd $HOME

wget -O filebot.deb http://sourceforge.net/projects/filebot/files/filebot/HEAD/FileBot_4.1.1/filebot_4.1_amd64.deb/download

sudo dpkg -i filebot.deb

rm filebot.deb