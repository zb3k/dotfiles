#!/bin/bash

source functions.sh



# ------------------------------------------------------------------------------
# Setup QT theme engine
# ------------------------------------------------------------------------------

print_header "Set qt theme engine"
if [[ $(cat /etc/environment | grep QT_QPA_PLATFORMTHEME) ]]; then
    print_skipping
else
    sudo bash -c 'echo "QT_QPA_PLATFORMTHEME=qt5ct" >> /etc/environment'
    print_success
fi


# ------------------------------------------------------------------------------
# Default wallpaper
# ------------------------------------------------------------------------------

print_header "Set default wallpaper"
feh --bg-fill ~/.wallpapers/rounded/sea-rock.png
print_success

# ------------------------------------------------------------------------------
# Enable bluetooth
# ------------------------------------------------------------------------------

# todo: use settings
print_header "Enable bluetooth"
if [[ $(systemctl status bluetooth | grep "active (running)") ]]; then
    print_skipping
else
    sudo systemctl enable bluetooth
    sudo systemctl start bluetooth
    print_success
fi


# ------------------------------------------------------------------------------
# Install Nordic theme
# ------------------------------------------------------------------------------

print_header "Nordic theme"
if [ -d ./public/.themes/Nordic ]; then
   print_skipping
else
    git clone https://github.com/EliverLara/Nordic "./public/.themes/Nordic"
    git clone -b darker https://github.com/EliverLara/Nordic "./public/.themes/Nordic-darker"
    print_success
fi


# ------------------------------------------------------------------------------
# Install Tela circle icons
# ------------------------------------------------------------------------------

print_header "Tela circle icons"
if [ -d .~/.local/share/icons/Tela-circle-nord ]; then
   print_skipping
else
    PWD=$(pwd)
    git clone https://github.com/vinceliuice/Tela-circle-icon-theme "/tmp/tela-circle-icon-theme"
    cd /tmp/tela-circle-icon-theme
    ./install.sh nord
    cd $PWD
    rm -rf /tmp/tela-circle-icon-theme
    print_success
fi