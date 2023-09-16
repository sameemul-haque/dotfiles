#!/usr/bin/env bash

dir="$HOME/.config/rofi"
theme='style-1'

## Run
rofi \
    -show filebrowser \
    -theme ${dir}/${theme}.rasi
