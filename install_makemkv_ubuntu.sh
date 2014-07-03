#!/bin/bash

cd $HOME

rm -rf makemkv-*

wget http://www.makemkv.com/download/makemkv-bin-1.8.11.tar.gz
wget http://www.makemkv.com/download/makemkv-oss-1.8.11.tar.gz

tar -xvf makemkv-bin-1.8.11.tar.gz
tar -xvf makemkv-oss-1.8.11.tar.gz

cd ./makemkv-bin-1.8.11
make
expect "Please type \"yes\" if you accept the terms of the license"
send "yes\n"
sudo make install

cd ../makemkv-oss-1.8.11
./configure
make
expect "Please type \"yes\" if you accept the terms of the license"
send "yes\n"
sudo make install

cd ..

rm -rf makemkv-*