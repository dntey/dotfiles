#!/bin/bash

# from https://ansonvandoren.com/posts/libinput-gestures-i3-workspaces/


CURRENT_NUM=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).num')
ALL_NUMS=($(i3-msg -t get_workspaces | jq -r '.[].num' | sort -n))
NEXT_WORKSPACE_NUM=0

for NUM in "${ALL_NUMS[@]}"; do
    if (( $CURRENT_NUM < $NUM )); then
        NEXT_WORKSPACE_NUM=$NUM
        break
    fi
done

if [ "$NEXT_WORKSPACE_NUM" -eq 0 ]; then
    HIGHEST_NUM=$(echo "${ALL_NUMS[@]}" | tr ' ' '\n' | sort -nr | head -1)
    [ -z "$HIGHEST_NUM" ] && NEXT_WORKSPACE_NUM=1 || NEXT_WORKSPACE_NUM=$((HIGHEST_NUM + 1))
fi

i3-msg workspace number "$NEXT_WORKSPACE_NUM"
