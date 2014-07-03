#!/bin/bash

cd $HOME

rm -rf makemkv-*

wget "http://www.makemkv.com/download/"
export curr_version=$(grep -m 1 "MakeMKV v" index.html | sed -e "s/.*MakeMKV v//;s/ (.*//")

echo "Scraped the MakeMKV download page and found the latest version as" ${curr_version}

export bin_zip=makemkv-bin-${curr_version}.tar.gz
export oss_zip=makemkv-oss-${curr_version}.tar.gz
export oss_folder=makemkv-oss-${curr_version}
export bin_folder=makemkv-bin-${curr_version}

wget http://www.makemkv.com/download/$bin_zip
wget http://www.makemkv.com/download/$oss_zip

tar -xzvf $bin_zip
tar -xzvf $oss_zip

rm index.html
rm $bin_zip
rm $oss_zip

cd ~/$oss_folder
./configure
make
make install

rm -rf ~/$oss_folder