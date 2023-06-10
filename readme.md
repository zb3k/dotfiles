# Arch / bspwm / dotfiles

## Скриншоты

`wip...`

## Используемое ПО

- **Arch linux** 
- **bspwm** - window manager
- **picom** (picom-ibhagwan-git) - compositor for Xorg 
- **polybar** - panel
- **sxhkd** - keybinding daemon
- **dunst** - notification daemon
- **rofi** - app launcher

## Установка

```bash
git clone https://github.com/zb3k/dotfiles
cd dotfiles
./install.sh
```

## Приватные файлы конфигураций (deprecated)

Вы можете дополнить установку своими собственными файлами конфигурации.

Для этого необходимо создать папку "**private**" со следующей струкутой файлов:

- **private/dotfiles** - папка с конфигурационными файлами (аналогична папке "**public**")

- **private/packages.txt** - файл со списком пакетов которые нужно установить

- **private/install.sh** - скрипт который будет автоматически запущен после вызова основного скрипта установки

Пример скрипта "**private/install.sh**":

```bash
#!/bin/bash

source '../functions.sh'

install_packages "packages.txt"
install_dotfiles "dotfiles"

```

## Горячие клавиши

`wip...`

## GTK Themes

- https://github.com/EliverLara/Nordic (darker branch for gtk, master branch for kvantum)
- https://github.com/Templarian/MaterialDesign-Webfont
- https://github.com/vinceliuice/Tela-circle-icon-theme

