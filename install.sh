#!/bin/bash

DEBUG=1
WAIT_SECONDS=0.5
SYMLINK_DOTFILES=1
SOURCE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PRIVATE_DIR="$SOURCE_DIR/private"

# ------------------------------------------------------------------------------
# Output helpers
# ------------------------------------------------------------------------------

BLACK='\e[30m';RED='\e[31m';GREEN='\e[32m';YELLOW='\e[33m'
BLUE='\e[34m';MAGENTA='\e[35m';CYAN='\e[36m';GRAY='\e[37m'
BG_BLACK='\e[40m\e[30m';BG_RED='\e[41m\e[30m';BG_GREEN='\e[42m\e[30m';BG_YELLOW='\e[43m\e[30m'
BG_BLUE='\e[44m\e[30m';BG_MAGENTA='\e[45m\e[30m';BG_CYAN='\e[46m\e[30m';BG_GRAY='\e[47m\e[30m'
NC='\e[0m'
HR=$(printf "%*s" "${COLUMNS:-$(tput cols)}" '' | tr ' ' '=')

print_header() { echo -e "\n$YELLOW$HR> $1 $BLUE$2$YELLOW\n$HR$NC\n"; sleep $WAIT_SECONDS; }
print_success() { echo -e "$BG_GREEN SUCCESS $NC"; }
print_skipping() { echo -e "$BG_CYAN SKIPPING $NC"; }

debug() { [ $DEBUG == 1 ] && echo -e "$GREY[ DEBUG ] $RED$1 $BLUE$2 $YELLOW$3 $CYAN$4 $NC"; }

# ------------------------------------------------------------------------------
# Common helpers
# ------------------------------------------------------------------------------

create_dir_if_needed() {
	[[ ! -w "$1" ]] && local SUDO_PREFIX="sudo "
	mkdir -p "$1"
}

link() {
	[[ $3 ]] && local CMD_PREFIX="sudo "
	[[ ! -w $(dirname "$2") ]] && SUDO_PREFIX="sudo "
	$(${SUDO_PREFIX}rm -rf "$2")
	if [[ $SYMLINK_DOTFILES == 1 ]]; then
		debug "LINK" "$1" "$2"
		$(${SUDO_PREFIX}ln -sf "$1" "$2")
	else
		debug "COPY" "$1" "$2"
		$(${SUDO_PREFIX}cp -rf "$1" "$2")
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
	print_header 'Install AUR helper' 'yay'
	if [ -e /usr/bin/yay ]; then
		print_skipping
	else
		rm -rf /tmp/aur_install
		sudo pacman --noconfirm --needed -S go
		git clone https://aur.archlinux.org/yay.git /tmp/aur_install
		cd /tmp/aur_install 
		makepkg -si --noconfirm 
		cd $SOURCE_DIR 
		rm -rf /tmp/aur_install
	fi
}

install_packages() {
	print_header "Install packages" "$1"
	[[ -f $1 ]] && local LAST_PACKAGE=$(tail -n 1 $1)
	if [ ! $LAST_PACKAGE ] || [ -e /usr/bin/$LAST_PACKAGE ]; then
		print_skipping
	else
		yay --noconfirm --needed -S - < $1
		print_success
	fi
}

install_dotfiles() {
	print_header "Install dotfiles" "$1"
	ls -bA -1 "$1" | while read file; do 
		local SRC="$1/$file"
		local TARGET="$HOME/$file"
		if [[ -d "$SRC" ]]; then
			link_childs "$SRC" "$TARGET"
		else
			link "$SRC" "$TARGET"
		fi
	done
	print_success
}

install_system_files() {
	print_header "Install system files" "$1$2"
	local SRC_DIR="$1$2"
	[[ -d "$SRC_DIR" ]] && link_files_deep "$SRC_DIR" "$2"
	print_success
}

exec_script() {
	print_header "Run script" "$1"
	if [[ -f $1 ]]; then
		$1
		print_success
	else
		print_skipping
	fi
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
update_system
install_xorg
install_aur

install_packages "$SOURCE_DIR/packages.txt"
install_dotfiles "$SOURCE_DIR/public"
install_system_files "$SOURCE_DIR" "/etc"

install_packages "$PRIVATE_DIR/packages.txt"
install_dotfiles "$PRIVATE_DIR/dotfiles"
install_system_files "$PRIVATE_DIR" "/etc"
exec_script "$PRIVATE_DIR/install.sh"

finalize

# ------------------------------------------------------------------------------
