#!/bin/bash

if pgrep -x "picom" > /dev/null
then
    killall picom
else
    picom -b --backend glx --window-shader-fg ~/.config/picom/shaders/redshift.glsl
fi
