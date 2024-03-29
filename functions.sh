#!/bin/bash



# Default settings (can override in settings.sh)
DEBUG=0
WAIT_SECONDS=0.5
SYMLINK_DOTFILES=0
DRIVER_PACKAGES=''

# System variables
SOURCE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SETTINGS_FILE="$SOURCE_DIR/settings.sh"

# Include settings if needed
[ -f $SETTINGS_FILE ] && source $SETTINGS_FILE

# ------------------------------------------------------------------------------
# Output helpers
# ------------------------------------------------------------------------------

COLS=${COLUMNS:-$(tput cols)}
BLACK='\e[30m';
RED='\e[31m';
GREEN='\e[32m';
YELLOW='\e[33m'
BLUE='\e[34m';
MAGENTA='\e[35m';
CYAN='\e[36m';
GRAY='\e[37m'
BG_BLACK='\e[40m\e[30m';
BG_RED='\e[41m\e[30m';
BG_GREEN='\e[42m\e[30m';
BG_YELLOW='\e[43m\e[30m'
BG_BLUE='\e[44m\e[30m';
BG_MAGENTA='\e[45m\e[30m';
BG_CYAN='\e[46m\e[30m';
BG_GRAY='\e[47m\e[30m'
NC='\e[0m'
HR=$(printf "%*s" "$COLS" '' | tr ' ' '=')
HR_ALT="$BG_YELLOW$HR$NC"

print_hr() {
	echo -e "$HR$NC$1"
}
section_begin() {
	print_hr
	echo -e "$BG_CYAN SECTION BEGIN $NC $BG_BLUE $1 $NC"
	print_hr "\n"
}

section_end() {
	echo -e "$BG_CYAN SECTION END $NC $BG_BLUE $1 $NC\n"
}

action() {
	ACTION_HEADER=$1
}
action_begin() {
	local CURRENT_FOLDER=$(basename $(pwd))
	local CURRENT_USER=$(whoami)
	echo -e "$BG_YELLOW $ACTION_HEADER $NC $BLUE$1 $GRAY[ $CURRENT_FOLDER ] $MAGENTA@$CURRENT_USER $NC\n"
	sleep $WAIT_SECONDS
	ACTION_PWD=$(pwd)
}
action_end() {
	ACTION_HEADER=""
	cd $ACTION_PWD
}
action_success() {
	echo -e "$BG_GREEN SUCCESS $NC\n"
	action_end
}
action_skipping() { 
	if [[ $ACTION_HEADER ]] ; then
		local PREFIX="$BG_YELLOW $ACTION_HEADER $NC"
	fi

	echo -e "$PREFIX $BG_GRAY SKIPPING $NC\n"
	action_end
}

debug() { 
	[ $DEBUG == 1 ] && echo -e "$GREY[ DEBUG ] $RED$1 $BLUE$2 $YELLOW$3 $CYAN$4 $NC"
}

# ------------------------------------------------------------------------------
# Common helpers
# ------------------------------------------------------------------------------

create_dir_if_needed() {
	[[ ! -w "$1" ]] && local CMD_PREFIX="sudo "
	$(${CMD_PREFIX}mkdir -p "$1")
}

link() {
	[[ ! -w $(dirname "$2") ]] && CMD_PREFIX="sudo "
	$(${CMD_PREFIX}rm -rf "$2")
	if [[ $SYMLINK_DOTFILES == 1 ]]; then
		debug "LINK" "$1" "$2"
		$(${CMD_PREFIX}ln -sf "$1" "$2")
	else
		debug "COPY" "$1" "$2"
		$(${CMD_PREFIX}cp -rf "$1" "$2")
	fi
}

link_childs() {
	debug "LINK_CHILDS" $1
	local SRC_DIR="$1"
	local TARGET_DIR="$2"
	create_dir_if_needed $TARGET_DIR
	ls -bA -1 "$SRC_DIR" | while read file; do
		link "$SRC_DIR/$file" "$TARGET_DIR/$file"
	done
}

link_files_deep() {
	debug "LINK_FILES_DEEP" $1 $2
	local SRC_DIR="$1"
	local TARGET_DIR="$2"
	create_dir_if_needed $TARGET_DIR
	ls -bA -1 "$SRC_DIR" | while read file; do
		local SRC="$SRC_DIR/$file"
		local TARGET="$TARGET_DIR/$file"
		if [[ -d "$SRC" ]]; then
			link_files_deep "$SRC" "$TARGET"
		else
			link "$SRC" "$TARGET"
		fi
	done
}

# ------------------------------------------------------------------------------
# Install functions
# ------------------------------------------------------------------------------

settings() {
	action "Settings"
	if [ -f $SETTINGS_FILE ]; then
		action_skipping
	else
		action_begin
		# SYMLINK_DOTFILES
		echo -e "[0] Copy (default)\n[1] Symlink\n"
		read -r -p "Use symlink or copy dotfiles: " SYMLINK_DOTFILES

		# DRIVER_PACKAGES
		echo -e "[0] No (default)\n[1] Intel\n[2] AMD\n[3] NVidia\n"
		read -r -p "Install video card driver: " DRV_TYPE
		case $DRV_TYPE in
			[0][*]) DRIVER_PACKAGES="" ;;
			[1]) DRIVER_PACKAGES='xf86-video-intel'  ;;
			[2]) DRIVER_PACKAGES='xf86-video-amdgpu' ;;
			[3]) DRIVER_PACKAGES='nvidia nvidia-settings nvidia-utils' ;;
		esac

		# Save settings file
		touch $SETTINGS_FILE
		echo "DEBUG=$DEBUG" >> $SETTINGS_FILE
		echo "WAIT_SECONDS=$WAIT_SECONDS" >> $SETTINGS_FILE
		echo "SYMLINK_DOTFILES=$SYMLINK_DOTFILES" >> $SETTINGS_FILE
		echo "DRIVER_PACKAGES='$DRIVER_PACKAGES'" >> $SETTINGS_FILE
		action_success
	fi
}

update_system() {
	action "Update system"
	action_begin
	sudo pacman --noconfirm -Syu
	action_success
}

install_xorg() {
	action "Install xorg"
	if [[ $(pacman -Q | grep "xorg-server ") ]]; then
		action_skipping
	else
		action_begin
		sudo pacman -S --noconfirm --needed xorg-server xorg-apps xorg-xinit xterm xorg-fonts-100dpi xorg-fonts-75dpi autorandr $DRIVER_PACKAGES
		action_success
	fi
}

install_aura() {
	action "Install AURA"
	if [ -e /usr/bin/aura ]; then
		action_skipping
	else
		action_begin
		rm -rf /tmp/aura_bin
		git clone https://aur.archlinux.org/aura-bin.git /tmp/aura_bin
		cd /tmp/aura_bin
		makepkg -si --noconfirm  
		cd $SOURCE_DIR
		rm -rf /tmp/aura_bin
		action_success
	fi
}

install_packages() {
	local PWD=$(pwd);
	local PACKAGES_FILE="$PWD/$1";
	[[ -f $PACKAGES_FILE ]] && local LAST_PACKAGE=$(tail -n 1 $PACKAGES_FILE)

	action "Install packages"
	if [ ! $LAST_PACKAGE ] || [[ $(pacman -Q | grep "$LAST_PACKAGE ") ]]; then
		action_skipping
	else
		action_begin $1
		sudo pacman --noconfirm --needed -S - < $PACKAGES_FILE
		action_success
	fi
}

install_aur_packages () {
	local PWD=$(pwd);
	local PACKAGES_FILE="$PWD/$1";
	[[ -f $PACKAGES_FILE ]] && local LAST_PACKAGE=$(tail -n 1 $PACKAGES_FILE)

	action "Install AUR packages"
	if [ ! $LAST_PACKAGE ] || [[ $(aura -Q | grep "$LAST_PACKAGE ") ]]; then
		action_skipping
	else
		action_begin $1
		sudo aura --noconfirm --needed -Aa - < $PACKAGES_FILE
		action_success
	fi
}

install_dotfiles() {
	action "Install dotfiles"
	action_begin "$1"
	local PWD=$(pwd);
	local SRC_DIR="$PWD/$1";
	ls -bA -1 "$SRC_DIR" | while read file; do 
		local SRC="$SRC_DIR/$file"
		local TARGET="$HOME/$file"
		if [[ -d "$SRC" ]]; then
			link_childs "$SRC" "$TARGET"
		else
			link "$SRC" "$TARGET"
		fi
	done
	action_success
}

install_system_files() {
	action "Install system files"
	action_begin "$1"
	local PWD=$(pwd);
	local SRC_DIR="$PWD/$1";
	local TARGET_DIR="/$1"
	[[ -d "$SRC_DIR" ]] && link_files_deep "$SRC_DIR" "$TARGET_DIR"
	action_success
}

exec_script() {
	action "RUN"
	if [[ -f $1 ]]; then
		action_begin $1
		# action_success
		local PWD=$(pwd)
		local SCRIPT_FILE="$PWD/$1"
		local SCRIPT_DIR=$(dirname $SCRIPT_FILE)
		cd $SCRIPT_DIR
		$SCRIPT_FILE
		cd $PWD
	else
		action_skipping
	fi
}
