#!/bin/bash

# Get pixel width of file
# mediainfo $file | grep "Width" | sed 's/^.*\(:\)//' | sed 's/\(pixels\).*//' | sed 's/\ //'