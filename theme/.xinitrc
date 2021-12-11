#!/bin/sh

if [ -f "$HOME/.Xresources" ]; then
    xrdb -merge "$HOME/.Xresources"
fi

if [ -f "$HOME/.Xmodmap" ]; then
    xmodmap "$HOME/.Xmodmap"
fi

# start some nice programs
# if [ -d /etc/X11/xinit/xinitrc.d ] ; then
#  for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
#   [ -x "$f" ] && . "$f"
#  done
#  unset f
# fi

# Gnome keyring
dbus-update-activation-environment --systemd DISPLAY
eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCKR

setxkbmap -layout us,ru -option "grp:caps_toggle,grp_led:caps" &

# xsetroot -cursor_name left_ptr &

wal -R &

liquidctl initialize &

dunst &

# maestral start &
~/.local/bin/maestral start &

picom &

nitrogen --restore &

# autodetect and mount USB drives
# udiskie &

exec bspwm 
