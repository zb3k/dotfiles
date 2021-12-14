#!/bin/bash

source functions.sh

# ------------------------------------------------------------------------------
# INSTALL
# ------------------------------------------------------------------------------

settings
update_system
install_xorg
install_aur

install_packages "packages.txt"
install_dotfiles "public"
install_system_files "etc"

exec_script "private/install.sh"

finalize

# ------------------------------------------------------------------------------
