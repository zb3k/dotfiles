#!/bin/bash

DEBUG=1

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[1;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

header() {
    printf "$PURPLE==================================================\n$1\n==================================================\n$NC"
}

debug() {
	if [[ $DEBUG ]]; then
		printf "   $RED[ $1 ] $BLUE$2 $ORANGE$3 $CYAN$4 $NC\n"
	fi
}

updateSystem() {
	header "Update system"
	sudo pacman --noconfirm -Syu
}

installXorg() {
	# install base-devel if not installed
	sudo pacman -S --noconfirm --needed base-devel wget git

	# choose video driver
	printf "[0] No (default)\n[1] Intel\n[2] AMD\n[3] NVidia\n"
	read -r -p "Install video card driver: " DRV_TYPE

	case $DRV_TYPE in
		[0][*])
			DRIVER_PACKAGES=""
			;;
		[1])
			DRIVER_PACKAGES='xf86-video-intel'
			;;
		[2])
			DRIVER_PACKAGES='xf86-video-amdgpu'
			;;
		[3])
			DRIVER_PACKAGES='nvidia nvidia-settings nvidia-utils'
			;;
	esac
	
	# install xorg if not installed
	sudo pacman -S --noconfirm --needed xorg xorg-xinit xorg-xinput $DRIVER_PACKAGES
}

# # install fonts
# mkdir -p ~/.local/share/fonts
# mkdir -p ~/.srcs

# cp -r ./fonts/* ~/.local/share/fonts/
# fc-cache -f
# clear 


# title="kizu's rice setup script"
# prefix="[\033[;32m*\033[0m]"

# downloadDependencies() {
#     if grep "Arch\|Artix\|EndeavourOS\|Manjaro" /etc/*-release; then
#         clear 
#         echo -e "$prefix Running an system update..."
#         sudo pacman --noconfirm -Syu

#         mkdir -p $HOME/.setup-scripto
#         sleep 0.5
#         clear

#         if [[ -e /usr/bin/paru ]]; then
#             echo -e "$prefix paru detected. Installing dependencies..."
#             paru -S bspwm sxhkd rofi polybar neovim alacritty dunst picom brightnessctl playerctl dunst feh maim viewnior jq xclip imagemagick bsp-layout i3lock-color
#         elif [[ -e /usr/bin/yay ]]; then
#             echo -e "$prefix yay detected. Installing dependencies..."
#             yay -S bspwm sxhkd rofi polybar neovim alacritty dunst picom brightnessctl playerctl dunst feh maim viewnior jq xclip imagemagick bsp-layout i3lock-color
#         else
#             # Line from https://github.com/Axarva/dotfiles-2.0/blob/9f0a71d7b23e1213383885f2ec641da48eb01681/install-on-arch.sh#L67
#             read -r -p "Would you like to install yay? [Y/n]: " yay
#             sleep 1.0

#             case $yay in
#                 [yY][*])
#                     git clone https://aur.archlinux.org/yay.git $HOME/.setup-scripto
#                     (cd $HOME/.setup-scripto && makepkg -si)

#                     echo -e "$prefix yay installed. Installing dependencies..."
#                     yay -S bspwm sxhkd rofi polybar neovim alacritty picom brightnessctl playerctl dunst feh maim viewnior jq xclip imagemagick bsp-layout i3lock-color
#                     ;;
#                 [nN])
#                     echo -e "$prefix Okay. Will not install yay."
#                     ;;
#             esac 
#         fi

#         sleep 1
#     else
#         clear
#         echo -e "$prefix Not on a Arch based system. Failed to download dependencies. Please manually install it."

#         sleep 1
#     fi
# }


# ------------------------------------------------------------------------------
# COMMON
# ------------------------------------------------------------------------------



symlink() {
	ln -sf $1 $2
	debug "symlink" $1 $2
}

link_dotfiles_to() {
	local DOTFILES_DIR="$1"
	local TARGET_DIR="$2"

	mkdir -p $TARGET_DIR

	debug "link_dotfiles_to" $1 $2

	for file in `ls -A $DOTFILES_DIR`; do
		local srcFile="$DOTFILES_DIR/$file"
		local targetFile="$TARGET_DIR/$file"
		if [[ $file == '.config' ]]; then
			link_dotfiles_to $srcFile "$targetFile"
		else
			symlink $srcFile $targetFile
		fi
	done
}

# ------------------------------------------------------------------------------
# PUBLIC
# ------------------------------------------------------------------------------

# updateSystem

# ------------------------------------------------------------------------------
# Install AUR helper if needed
# ------------------------------------------------------------------------------
if [ ! -e /usr/bin/yay ]; then
    header 'Install AUR helper (yay)'
	rm -rf /tmp/aur_install
	sudo pacman --noconfirm --needed -S go
	git clone https://aur.archlinux.org/yay.git /tmp/aur_install
	cd /tmp/aur_install 
	makepkg -si --noconfirm 
	cd $SCRIPT_DIR 
	rm -rf /tmp/aur_install
fi

# ------------------------------------------------------------------------------
# Install packages
# ------------------------------------------------------------------------------
header "Install packages"
yay --noconfirm --needed -S\
	picom-ibhagwan-git\
	bspwm\
	sxhkd\
	rofi\
	dunst\
	polybar\
	nitrogen\
	kitty\
	jq

# ------------------------------------------------------------------------------
# Link config
# ------------------------------------------------------------------------------
link_dotfiles_to "$SCRIPT_DIR/theme" $HOME