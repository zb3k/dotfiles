#!/bin/bash

SOURCE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
POSTINSTALL_SCRIPT="$SOURCE_DIR/private/install.sh"
RUN="$SOURCE_DIR/run.sh"

# ------------------------------------------------------------------------------
# INSTALL
# ------------------------------------------------------------------------------

# $RUN settings
$RUN update_system
$RUN install_xorg
$RUN install_aur

$RUN install_packages "$SOURCE_DIR/packages.txt"
$RUN install_dotfiles "$SOURCE_DIR/public"
$RUN install_system_files "$SOURCE_DIR" "/etc"

$RUN exec_script "$POSTINSTALL_SCRIPT"

$RUN finalize

# ------------------------------------------------------------------------------
