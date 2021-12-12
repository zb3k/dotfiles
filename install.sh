#!/bin/bash

DEBUG=0
WAIT_SECONDS=0.5
SYMLINK_DOTFILES=1
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PRIVATE_DIR=$SCRIPT_DIR/private


# ------------------------------------------------------------------------------
# Output helpers
# ------------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
GREY='\033[0;37m'
NC='\033[0m'

print_header() { echo -e "$ORANGE##########   $1   ##########$NC"; sleep $WAIT_SECONDS; }
print_success() { echo -e "$GREEN[ SUCCESS ]$NC"; }
print_skipping() { echo -e "$CYAN[ SKIPPING ]$NC"; }

debug() { [ $DEBUG == "1" ] && echo -e "$GREY[ DEBUG ] $RED[ $1 ] $BLUE$2 $ORANGE$3 $CYAN$4 $NC"; }

# ------------------------------------------------------------------------------
# Common helpers
# ------------------------------------------------------------------------------

copy_or_link() {
	rm -rf "$2"
	if [[ $SYMLINK_DOTFILES == "1" ]]; then
		debug "LINK" "$1" "$2"
		ln -s "$1" "$2"
	else
		debug "COPY" "$1" "$2"
		cp -r "$1" "$2"
	fi
}

copy_or_link_dir() {
	debug "LINK DIR" $1 $2
	local SRC_DIR="$1"
	local TARGET_DIR="$2"
	local FORCE_LINK=$3
	mkdir -p "$TARGET_DIR"
	ls -bA -1 "$SRC_DIR" | while read file; do 
		local SRC="$SRC_DIR/$file"
		local TARGET="$TARGET_DIR/$file"
		if [[ -d "$SRC" ]] && [ ! $FORCE_LINK ]; then
			copy_or_link_dir "$SRC" "$TARGET" "FORCE_LINK"
		else
			copy_or_link "$SRC" "$TARGET"
		fi
	done
}

# ------------------------------------------------------------------------------
# Install functions
# ------------------------------------------------------------------------------

settings() {
	print_header "Settings"
	
	if [ ! $SYMLINK_DOTFILES ]; then
		echo -e "[0] Copy (default)\n[1] Symlink\n"
		read -r -p "Use symlink or copy dotfiles: " SYMLINK_DOTFILES
	fi

	print_success
}

update_system() {
	print_header "Update system"
	sudo pacman --noconfirm -Syu
	print_success
}

install_xorg() {
	print_header "Install xorg"
	echo -e "[0] No (default)\n[1] Intel\n[2] AMD\n[3] NVidia\n"
	read -r -p "Install video card driver: " DRV_TYPE
	case $DRV_TYPE in
		[0][*]) DRIVER_PACKAGES="" ;;
		[1]) DRIVER_PACKAGES='xf86-video-intel'  ;;
		[2]) DRIVER_PACKAGES='xf86-video-amdgpu' ;;
		[3]) DRIVER_PACKAGES='nvidia nvidia-settings nvidia-utils' ;;
	esac
	# sudo pacman -S --noconfirm --needed xorg xorg-xinit xorg-xinput $DRIVER_PACKAGES
	sudo pacman -S --noconfirm --needed xorg-server xorg-utils xorg-apps $DRIVER_PACKAGES
	print_success
}

install_aur() {
	print_header 'Install AUR helper (yay)'
	if [ -e /usr/bin/yay ]; then
		print_skipping
	else
		rm -rf /tmp/aur_install
		sudo pacman --noconfirm --needed -S go
		git clone https://aur.archlinux.org/yay.git /tmp/aur_install
		cd /tmp/aur_install 
		makepkg -si --noconfirm 
		cd $SCRIPT_DIR 
		rm -rf /tmp/aur_install
	fi
}

install_packages() {
	print_header "Install packages [ $1 ]"
	local FIRST_PACKAGE=$(head -n 1 $SCRIPT_DIR/$1)
	if [ -e /usr/bin/$FIRST_PACKAGE ]; then
		print_skipping
	else
		yay --noconfirm --needed -S - < $1
		print_success
	fi
}

install_dotfiles() {
	print_header "Install dotfiles [ $1 ]"
	copy_or_link_dir "$SCRIPT_DIR/$1" $HOME	
	print_success
}

finalize() {
	print_header "Finalize"
	fc-cache
	print_success
}

# ------------------------------------------------------------------------------
# INSTALL
# ------------------------------------------------------------------------------

settings

# update_system

# install_xorg

# install_aur

# install_packages packages.txt

# install_packages private-packages.txt

install_dotfiles "public"

install_dotfiles "private"

# finalize