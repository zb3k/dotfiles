#!/bin/bash

systemctl enable bluetooth
systemctl start bluetooth

# Nordic theme
print_header "Nordic theme"
git clone https://github.com/EliverLara/Nordic "$SOURCE_DIR/public/.themes/Nordic"
git clone -b darker https://github.com/EliverLara/Nordic "$SOURCE_DIR/public/.themes/Nordic-darker"
print_success

# Tela circle icons
print_header "Tela circle icons"
git clone https://github.com/vinceliuice/Tela-circle-icon-theme "$SOURCE_DIR/extra/tela-circle-icon-theme"
cd "$SOURCE_DIR/extra/tela-circle-icon-theme"
./install.sh -a
print_success
