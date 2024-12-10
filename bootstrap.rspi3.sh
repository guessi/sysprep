#!/bin/bash

set -e

# verified with clean raspberry-pi-os (debian 12)
# - https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-64-bit
# - https://www.raspberrypi.com/documentation/computers/os.html

# check os code name
if [ "$(lsb_release -sc)" != "bookworm" ]; then
  echo "Debian 12 (Bookworm) is the only supported version"
  exit 1
fi

# must be execute as default user
if [ $(id -u) -ne 1000 ]; then
  echo "please run the script with default user \"pi (uid: 1000)\""
  exit 1
fi

# system upgrade
sudo apt update
sudo apt upgrade -y

# better working environment
sudo apt install --no-install-recommends -y                                   \
  colordiff                                                                   \
  fonts-wqy-microhei                                                          \
  fonts-wqy-zenhei                                                            \
  git-extras                                                                  \
  jq                                                                          \
  ripgrep                                                                     \
  tig                                                                         \
  vim                                                                         \
  vlc

# remove unwanted default packages
sudo apt purge -y                                                             \
  debian-reference-common                                                     \
  debian-reference-en

# cleanup
sudo apt autoremove -y

# remove unwanted menu items
sudo rm -vf /usr/share/raspi-ui-overrides/applications/debian-reference-common.desktop
sudo rm -vf /usr/share/raspi-ui-overrides/applications/magpi.desktop
sudo rm -vf /usr/share/raspi-ui-overrides/applications/raspi_getstart.desktop
sudo rm -vf /usr/share/raspi-ui-overrides/applications/raspi_help.desktop
sudo rm -vf /usr/share/raspi-ui-overrides/applications/raspi_resources.desktop

# unhide useful menu items
sudo sed -i '/^NoDisplay/s/true/false/' /usr/share/raspi-ui-overrides/applications/htop.desktop

# cleanup default directories if not empty
rmdir -v ~/{Documents,Downloads,Music,Pictures,Public,Templates,Videos} 2>/dev/null || true

# locale setup
sudo debconf-set-selections <<< 'locales locales/default_environment_locale select en_US.UTF-8'
sudo dpkg-reconfigure --frontend=noninteractive locales
sudo update-locale
