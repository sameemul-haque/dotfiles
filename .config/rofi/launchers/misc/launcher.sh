#!/usr/bin/env bash

theme="screen"
dir="$HOME/.config/rofi/launchers/misc"

rofi -x11 -no-lazy-grab -show drun -modi drun -theme $dir/"launchpad"
