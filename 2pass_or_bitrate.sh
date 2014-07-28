#!/bin/bash

# mediainfo must be installed before use. On a mac, it can be installed using Homebrew: `brew install mediainfo`

rc_value_string=$(mediainfo "$1" | grep 'rc=' | cut -d'/' -f 39)
rc_value=$(echo ${rc_value_string:4})

if [[ "$rc_value" == "crf" ]]; then
	echo "
The file $(basename "$1") has been encoded using a constant rate factor
" >&2
else
	echo "
The file $(basename "$1") has been encoded using a nominal bit rate
" >&2
fi