# Media Server Scripts to Download, Rip, Import, Transcode, and Watch your media collection

## Steady there tiger!

Before we start, please just check a few things. You must be able to and know how to do the following things:

* Use a terminal emulator
* Have physical access to your computer
* Be running either Mac OS X 10.9 or Ubuntu 14.04 LTS (Desktop or Server are tested)

## Mac Install

Firstly, go to the Mac App Store and download Xcode. You can also do so by clicking [this link](https://itunes.apple.com/gb/app/xcode/id497799835?mt=12) and then clicking on install app.

Once Xcode has been downloaded, you can open your terminal to install the command line tools we'll need for the script by running the following command:

	xcode-select --install

Follow the instructions and before you know it they should be installed too!

Finally, it's import to accept the license agreements for Xcode. To do this, open Xcode and accept them, or run this command and follow the instructions:

	sudo xcodebuild -license

Now you're ready to get going!

To download the latest version of this repository issue the following command:

	git clone http://www.github.com/FreddieShoreditch/media_server.git

Once this has completed, go to into the git directory you just downloaded in terminal, and then issue the following command to install the scripts to your system:

	./media_server/install.sh

## Mac Update

The time comes when we eventually need to update things.

To do this, go into the git directory you originally downloaded, and then issue the following command to update and re-install the code:

	 cd media_server && git pull origin master && cd

Then you can run the install script again:

	./media_server/install.sh

## Ubuntu (Desktop) Install

## Ubuntu (Server) Install