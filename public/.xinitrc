#!/bin/sh

if [ -f "$HOME/.Xresources" ]; then
    xrdb -merge "$HOME/.Xresources"
fi

if [ -f "$HOME/.Xmodmap" ]; then
    xmodmap "$HOME/.Xmodmap"
fi

Private part .xinitrc
if [ -f "$HOME/.xinitrc-private" ]; then
    source $HOME/.xinitrc-private
fi

exec bspwm