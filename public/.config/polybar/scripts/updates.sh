#!/bin/bash

if ! updates_arch="$(pacman -Qu | wc -l)"; then
    updates_arch=0
fi

if ! updates_aur="$(pacman -Qum 2>/dev/null | wc -l)"; then
    updates_aur=0
fi

updates="$((updates_arch + updates_aur))"

if [ "$updates" -gt 0 ]; then
    echo "$updates_arch:$updates_aur"
fi