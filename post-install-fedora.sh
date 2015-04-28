#!/bin/sh

DISTRO=$(awk -F'=' '/^NAME=/{print$2}' /etc/os-release)

if [ ${DISTRO} != 'Fedora' ]; then
  echo "Sorry, this script was written for Fedora only"
  exit 1
fi

OS_VERSION=$(awk -F'=' '/VERSION_ID=/{print$2}' /etc/os-release)

RPM_IMPORT="sudo rpm --import"
RPM_INSTALL="sudo rpm -ivh"
YUM_INSTALL="sudo yum install -y"
YUM_UPDATE="sudo yum update -y"

# detect current running user
if [ ! -z ${SUDO_USER} ]; then
  HOMEDIR=$(eval echo ~${SUDO_USER})
else
  HOMEDIR=${HOME}
fi

# bashrc
if [ -f ${HOMEDIR}/.bashrc ]; then
  cp ${HOMEDIR}/.bashrc ${HOMEDIR}/.bashrc.bak
fi
cp _bashrc ${HOMEDIR}/.bashrc

# vimrc
if [ -f ${HOMEDIR}/.vimrc ]; then
  cp ${HOMEDIR}/.vimrc ${HOMEDIR}/.vimrc.bak
fi
cp _vimrc ${HOMEDIR}/.vimrc

# ensure we are running with latest yum toolkit
${YUM_UPDATE} yum

# ssh services
${YUM_INSTALL} openssh-clients
${YUM_INSTALL} openssh-server

# security upgrade for heartbleed and shellshock
${YUM_INSTALL} bash openssl

# develop tools
${YUM_INSTALL} git gitg tig
${YUM_INSTALL} curl colordiff meld vim wget
${YUM_INSTALL} ethtool htop iftop iperf tcpdump

# general tools
${YUM_INSTALL} p7zip p7zip-plugins unzip

# adobe flash plugin
${RPM_INSTALL} http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
${RPM_IMPORT} /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
${YUM_INSTALL} flash-plugin

# multimedia
${YUM_INSTALL} nspluginwrapper alsa-plugins-pulseaudio libcurl

# multimedia (rpmfusion)
${RPM_INSTALL} http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm
${RPM_INSTALL} http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm

${YUM_INSTALL} ffmpeg gstreamer gstreamer-ffmpeg \
               gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-ugly \
               gstreamer-plugins-bad gstreamer-plugins-bad-free gstreamer-plugins-bad-nonfree
${YUM_INSTALL} vlc

# general tools (rpmfusion)
${YUM_INSTALL} unrar

# communication
${YUM_INSTALL} pidgin pidgin-sipe

# input method
${YUM_INSTALL} ibus-chewing

# gnome toolkits
${YUM_INSTALL} gnome-tweak-tool dconf-editor
${YUM_INSTALL} gnome-shell-extension-alternate-tab
${YUM_INSTALL} gnome-shell-extension-pidgin
${YUM_INSTALL} gnome-shell-extension-user-theme

# desktop experience
${YUM_INSTALL} nautilus-open-terminal
${YUM_INSTALL} gnome-shell-theme-zukitwo

gsettings set org.gnome.shell always-show-log-out true

# google chrome
sudo tee /etc/yum.repos.d/google-chrome.repo > /dev/null << EOF
[google-chrome]
name=google-chrome - 64-bit
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF

${YUM_INSTALL} google-chrome-stable

# dropbox
sudo tee /etc/yum.repos.d/dropbox.repo > /dev/null << EOF
[Dropbox]
name=Dropbox Repository
baseurl=http://linux.dropbox.com/fedora/\$releasever/
gpgkey=https://linux.dropbox.com/fedora/rpm-public-key.asc
EOF

${YUM_INSTALL} nautilus-dropbox

# system update
${YUM_UPDATE}
