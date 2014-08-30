# Media Server Scripts to Download, Rip, Import, Transcode, and Watch your media collection

## Steady there tiger!

Before you read or download anything, please just check a few things. You must be able to and know how to do the following things:

* Use a terminal emulator
* Have physical access to your computer
* Be running either Mac OS X 10.9 or Ubuntu 14.04 LTS (Desktop or Server are tested)

It is STRONGLY recommended you have a quad-core machine to run these scripts, or if not, a Core i5 or above processor, preferably with hyper-threading enabled. If you're running Mac OS X, a Mac from 2011 or later will generally suffice. You will see considerable performance issues if the processor of the machine you intend to run these scripts on is underpowered.

## What does it do?

1.	Upon inserting a disc into your computer, allows you to issue the following command to rip the disc as an MKV to your computer with a name of your choice. There are two arguments to the script as shown below. {disc kind} should be replace with either movie or tv dependent on the content kind. {disc name} should be replaced with the title of the film and a year if possible (quoted) for a movie, or the name of the show and the season number (with a hyphon between).

	discripper {disc kind} {disc name}

	Examples:
	discripper movie "Die Another Day (2002)"
	discripper movie "Ted (2012)"
	discripper tv "New Girl - Season 03"
	discripper tv "Downton Abbey - Season 01"

2.	Transcodes all your media in movie and TV folders which you specify. For movies, these are transcoded into a smaller and a larger file, one for mobile use and one for high definition viewing from home clients. For TV, these are transcoded into one file at the original resolution. To achieve this, you can issue a command with the arguments of either "movie" or "tv". For each argument, the transcoder will go through all the files in the movie/tv directory, one by one, and transcode them as specified. 

	Examples:
	plextranscoder movie
	plextranscoder tv

3.	Downloads new media using open source software. This must be done responsibly and I hold no responsibility for anyone who downloads these scripts and uses them for irresponsible and illegal means. 
	To add media to be downloaded run the following command with either the torrent or the magnet link:
	
	tremote -a [torrent location/magnet link]
	
	To monitor your downloads, go to http://[IP ADDRESS OF YOUR MACHINE]:9091 where the username and password will be those set upon install.

## Pre-installation

### Mac

Firstly, go to the Mac App Store and download Xcode. You can also do so by clicking [this link](https://itunes.apple.com/gb/app/xcode/id497799835?mt=12) and then clicking on install app.

![](https://raw.githubusercontent.com/FreddieShoreditch/media_server/development/.images/Screen%20Shot%202014-08-13%20at%2018.48.23.png)

Once Xcode has been downloaded, you can open your terminal to install the command line tools we'll need for the script by running the following command:

	xcode-select --install

![](https://raw.githubusercontent.com/FreddieShoreditch/media_server/development/.images/Screen%20Shot%202014-08-13%20at%2019.17.19.png)

Follow the instructions and before you know it they should be installed too!

![](https://raw.githubusercontent.com/FreddieShoreditch/media_server/development/.images/Screen%20Shot%202014-08-13%20at%2019.17.52.png)

Finally, it's import to accept the license agreements for Xcode. To do this, open Xcode and accept them, or run this command and follow the instructions:

	sudo xcodebuild -license

### Ubuntu Desktop or Server

Firstly, go into terminal and type in the following command to ensure you have `git` installed:

	sudo apt-get -y install git

Secondly, create a directory for the git repository by issuing this command (default is /usr/local/media_server as below - may be changed as per your requirements but remember where you've put it and change the commands to follow to reflect this!):

	sudo mkdir /usr/local/media_server

Thirdly, we need to make sure you actually own the 

	whoami | sudo chown -R "$(cat -)" /usr/local/media_server

## Installation

Installation is very simple and exactly the same on the supported platforms.

It installs to /usr/local/media_server by default, remembering that if you're on an Ubuntu machine, this must be changed to be the same as the directory you created in the pre-installation procedure.

To download the latest version of this repository issue the following command:

# Changed for final release
	git clone -b release http://www.github.com/FreddieShoreditch/media_server.git /usr/local/media_server 

Once this has completed issue the following command to install the scripts to your system:

	sudo /usr/local/media_server/install.sh

## Post-installation (updating and removal)

### Updating

The time comes when we eventually need to update things.

Luckily, included is a script that should take care of this for you.
Just run the following command:

	gitupdate /usr/local/media_server

Note: If you have changed the directory where the git repository is saved, you will need to alter the above command accordingly. This will only work for the default directory at the moment.

### Removing

The removal process is similarly simple, just run the following command in terminal:

	media_server_remove
