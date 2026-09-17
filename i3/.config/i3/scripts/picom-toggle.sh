#!/usr/bin/env bash

config="$HOME/.config/picom/picom.conf"
shader="$HOME/.config/picom/shaders/redshift.glsl"

# A running picom with this shader means the next state is normal; otherwise
# enable the shader.  Stop the old compositor before starting its replacement.
if pgrep -a -x picom | grep -Fq -- "$shader"; then
    picom_args=()
else
    picom_args=(--backend glx --window-shader-fg "$shader")
fi

pkill -x picom 2>/dev/null || true
while pgrep -x picom >/dev/null; do
    sleep 0.1
done

picom --config "$config" -b "${picom_args[@]}"
