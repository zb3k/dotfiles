#!/bin/bash

source functions.sh

# ------------------------------------------------------------------------------
# INSTALL
# ------------------------------------------------------------------------------

settings
update_system
install_aur
install_xorg

install_packages "packages/system-alsa.txt"
install_packages "packages/system-pipewire.txt"
install_packages "packages/system-bluetooth.txt"

install_packages "packages/wm.txt"
install_packages "packages/wm-tools.txt"

install_packages "packages/trash.txt"

install_dotfiles "public"

exec_script "postinstall.sh"

exec_script "private/install.sh"

# install_system_files "etc"

finalize

# ------------------------------------------------------------------------------
