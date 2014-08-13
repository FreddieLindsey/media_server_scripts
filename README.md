# Media Server Scripts to Download, Rip, Import, Transcode, and Watch your media collection

## Steady there tiger!

Before we start, please just check a few things. You must be able to and know how to do the following things:

* Use a terminal emulator
* Have physical access to your computer
* Be running either Mac OS X 10.9 or Ubuntu 14.04 LTS (Desktop or Server are tested)

## Mac Install

Firstly, go to the Mac App Store and download Xcode. You can also do so by clicking ![this link](https://www.google.co.uk/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0CCIQFjAA&url=https%3A%2F%2Fitunes.apple.com%2Fgb%2Fapp%2Fxcode%2Fid497799835%3Fmt%3D12&ei=vKbrU8maIqvQ7AbxuoHQCQ&usg=AFQjCNFzwzu0w6T5iD4Bt9I0B0uByLrOFw) and then clicking on install app.

Once Xcode has been downloaded, you can open your terminal to install the command line tools we'll need for the script by running the following command:

	xcode-select --install

Follow the instructions and before you know it they should be installed too!

Now you're ready to get going!

To download the latest version of this repository issue the following command:

	git clone http://www.github.com/FreddieShoreditch/media_server.git

Once this has completed, go to into the git directory you just downloaded in terminal, and then issue the following command to install the scripts to your system:

	sh install.sh

## Mac Update

The time comes when we eventually need to update things.

To do this, go into the git directory you originally downloaded, and then issue the following command to update and re-install the code:

	git pull origin master && sh install.sh

## Ubuntu (Desktop) Install

## Ubuntu (Server) Install