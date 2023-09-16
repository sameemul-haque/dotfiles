#!/usr/bin/env bash

dir="$HOME/.config/rofi"
theme='style-1'

## Run
rofi \
    -show emoji \
    -theme ${dir}/${theme}.rasi
