#!/bin/bash

source functions.sh

section_begin "public/postinstall"

# ------------------------------------------------------------------------------
# Setup QT theme engine
# ------------------------------------------------------------------------------

action "Set qt theme engine"
if [[ $(cat /etc/environment | grep QT_QPA_PLATFORMTHEME) ]]; then
    action_skipping
else
    action_begin
    sudo bash -c 'echo "QT_QPA_PLATFORMTHEME=qt5ct" >> /etc/environment'
    action_success
fi

# ------------------------------------------------------------------------------
# Default wallpaper
# ------------------------------------------------------------------------------

action "Set default wallpaper"
action_begin
feh --bg-fill "$HOME/.wallpapers/rounded/sea-rock.png"
action_success

# ------------------------------------------------------------------------------
# Enable bluetooth
# ------------------------------------------------------------------------------

# todo: use settings
action "Enable bluetooth"
if [[ $(systemctl status bluetooth | grep "active (running)") ]]; then
    action_skipping
else
    action_begin
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
    action_success
fi

# ------------------------------------------------------------------------------
# Install Nordic theme
# ------------------------------------------------------------------------------

action "Nordic theme"
if [ -d "$HOME/.local/share/themes/Nordic" ]; then
    action_skipping
else
    action_begin
    mkdir -p "$HOME/.local/share/themes/"
    git clone https://github.com/EliverLara/Nordic "$HOME/.local/share/themes/Nordic"
    git clone -b darker https://github.com/EliverLara/Nordic "$HOME/.local/share/themes/Nordic-darker"
    action_success
fi

# ------------------------------------------------------------------------------
# Install Tela circle icons
# ------------------------------------------------------------------------------

action "Tela circle icons"
if [ -d "$HOME/.local/share/icons/Tela-circle-nord" ]; then
    action_skipping
else
    action_begin
    PWD=$(pwd)
    git clone https://github.com/vinceliuice/Tela-circle-icon-theme "/tmp/tela-circle-icon-theme"
    cd /tmp/tela-circle-icon-theme
    ./install.sh nord
    cd $PWD
    rm -rf /tmp/tela-circle-icon-theme
    action_success
fi

# ------------------------------------------------------------------------------

section_end "public/postinstall"