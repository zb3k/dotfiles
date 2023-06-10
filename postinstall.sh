#!/bin/bash

source functions.sh

sudo bash -c 'echo "QT_QPA_PLATFORMTHEME=qt5ct" >> /etc/environment'

# systemctl enable bluetooth
# systemctl start bluetooth

# Nordic theme
print_header "Nordic theme"
if [ -d ./public/.themes/Nordic ]; then
    print_skipping
else
    git clone https://github.com/EliverLara/Nordic "./public/.themes/Nordic"
    git clone -b darker https://github.com/EliverLara/Nordic "./public/.themes/Nordic-darker"
    print_success
fi

# Tela circle icons
print_header "Tela circle icons"
PWD=$(pwd)
git clone https://github.com/vinceliuice/Tela-circle-icon-theme "/tmp/tela-circle-icon-theme"
cd /tmp/tela-circle-icon-theme
./install.sh nord
cd $PWD
rm -rf /tmp/tela-circle-icon-theme
print_success
