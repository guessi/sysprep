#!/bin/bash

set -e

# check os version
if [ "$(lsb_release -ds | cut -d' ' -f1)" != "Raspbian" ]; then
  echo "support raspbian only"
  exit 1
fi

# check os code name
if [ "$(lsb_release -sc)" != "stretch" ]; then
  echo "support stretch only"
  exit 1
fi

# must be execute as default user
if [ $(id -u) -ne 1000 ]; then
  echo "support uid 1000 only"
  exit 1
fi

# speed up installation
echo "deb http://free.nchc.org.tw/raspbian/raspbian/ stretch main contrib non-free rpi" | sudo tee /etc/apt/sources.list

# system upgrade
sudo apt update
sudo apt upgrade -y

# better working environment
sudo apt install -y                                                           \
         colordiff                                                            \
         firefox-esr                                                          \
         git-extras                                                           \
         jq                                                                   \
         meld                                                                 \
         scim-chewing                                                         \
         tig                                                                  \
         vim                                                                  \
         vlc

# remove unwanted default packages
sudo apt purge -y                                                             \
         bluej                                                                \
         claws-mail                                                           \
         epiphany-browser                                                     \
         geany                                                                \
         geany-common                                                         \
         greenfoot                                                            \
         idle                                                                 \
         idle3                                                                \
         minecraft-pi                                                         \
         nodejs                                                               \
         nodejs-legacy                                                        \
         nodered                                                              \
         python3-jedi                                                         \
         python3-thonny                                                       \
         scratch                                                              \
         scratch2                                                             \
         sonic-pi                                                             \
         wolfram-engine

# (optional) remove chromium-browser
sudo apt purge -y chromium-browser

# cleanup
sudo apt autoremove -y

# remove unwanted menu items
sudo rm -rf /usr/share/raspi-ui-overrides/applications/debian-reference-common.desktop
sudo rm -rf /usr/share/raspi-ui-overrides/applications/magpi.desktop
sudo rm -rf /usr/share/raspi-ui-overrides/applications/python-games.desktop
sudo rm -rf /usr/share/raspi-ui-overrides/applications/raspi_resources.desktop

# unhide useful menu items
sudo sed -i '/^NoDisplay/s/true/false/' /usr/share/raspi-ui-overrides/applications/htop.desktop

# cleanup unwanted contents after packages removal
rm -rf ~/.config/chromium
rm -rf ~/.config/geany/
rm -rf ~/.config/sonic-pi.net/
rm -rf ~/.thonny/
rm -rf ~/Documents/*
rm -rf ~/python_games

# cleanup default directories if not empty
rmdir Documents Downloads Music Pictures Public Templates Videos 2>/dev/null || true
