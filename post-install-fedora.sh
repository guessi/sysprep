#!/bin/sh

DISTRO="$(awk -F'=' '/^NAME=/{print$2}' /etc/os-release)"

if [ "$(whoami)" = "root" ]; then
  echo "Please DO NOT execute the script the user who have \`sudo\` permission"
  exit 1
fi

if [ "${DISTRO}" != "Fedora" ]; then
  echo "Sorry, this script was written for Fedora only"
  exit 1
fi

OS_VERSION="$(awk -F '=' '/^VERSION_ID=/{print$2}' /etc/os-release)"

if [ "$(whoami)" != "root" ]; then
  SUDO='sudo -E'
else
  SUDO=''
fi

RPM_IMPORT="${SUDO} rpm --import"
RPM_INSTALL="${SUDO} rpm -ivh"

DO_INSTALL="${SUDO} dnf install -y"
DO_UPDATE="${SUDO} dnf update -y"

# detect current running user
if [ -n "${SUDO_USER}" ]; then
  HOMEDIR="$(eval echo ~"${SUDO_USER}")"
else
  HOMEDIR="${HOME}"
fi

# bashrc
if [ -f "${HOMEDIR}/.bashrc" ]; then
  cp "${HOMEDIR}/.bashrc" "${HOMEDIR}/.bashrc.bak"
fi
cp _bashrc "${HOMEDIR}/.bashrc"

# vimrc
if [ -f "${HOMEDIR}/.vimrc" ]; then
  cp "${HOMEDIR}/.vimrc" "${HOMEDIR}/.vimrc.bak"
fi
cp _vimrc "${HOMEDIR}/.vimrc"

# ssh config
mkdir -p "${HOMEDIR}/.ssh"
cat > "${HOMEDIR}/.ssh/config" <<-EOF
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
  ServerAliveInterval 60
  LogLevel=quiet
EOF
chmod 0640 "${HOMEDIR}/.ssh/config"

# ensure we are running with latest dnf
${DO_UPDATE} dnf

# ssh services
${DO_INSTALL} openssh-clients
${DO_INSTALL} openssh-server

# security upgrade for heartbleed and shellshock
${DO_INSTALL} bash openssl

# develop tools
${DO_INSTALL} git gitg tig git-extras
${DO_INSTALL} curl colordiff meld vim wget
${DO_INSTALL} ethtool htop iftop iperf tcpdump

# git global settings
git config --global diff.tool colordiff
git config --global core.editor vim
git config --global color.ui true
git config --global alias.ci commit
git config --global alias.co checkout
git config --global alias.dc 'diff --cached'
git config --global alias.find '!git ls-files | grep -i'
git config --global alias.hist 'log --pretty=format:"%C(yellow)%h%C(reset) %C(dim green)%ad%C(reset) %s%C(red)%d%C(reset) [%C(cyan)%an%C(reset)]" --graph --date=short'
git config --global alias.lo 'log --oneline --decorate'
git config --global alias.lt '!git describe --tags --abbrev=0 2>/dev/null || echo "not tag defined"'
git config --global alias.st 'status -s'
git config --global push.default simple

# create link for git-prompt.sh
if [ -f /etc/profile.d/git-prompt.sh ] || [ -L /etc/profile.d/git-prompt.sh ]; then
  ${SUDO} rm -vf /etc/profile.d/git-prompt.sh
fi

if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
  ${SUDO} ln -s -f /usr/share/git-core/contrib/completion/git-prompt.sh /etc/profile.d/
fi

# general tools
${DO_INSTALL} p7zip p7zip-plugins unzip libcurl

# bbs
${DO_INSTALL} pcmanx-gtk2

# irc
${DO_INSTALL} hexchat

# chinese fonts
${DO_INSTALL} wqy-zenhei-fonts wqy-microhei-fonts

# input method
${DO_INSTALL} ibus-chewing

# gnome toolkits
${DO_INSTALL} gnome-tweak-tool dconf-editor
${DO_INSTALL} gnome-shell-extension-alternate-tab
${DO_INSTALL} gnome-shell-extension-user-theme
${DO_INSTALL} nautilus-open-terminal

gsettings set org.gnome.shell always-show-log-out true

# multimedia
${DO_INSTALL} alsa-plugins-pulseaudio

# multimedia (rpmfusion)
${RPM_INSTALL} "http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm"
${RPM_INSTALL} "http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm"

${DO_INSTALL} ffmpeg gstreamer gstreamer-ffmpeg \
               gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-ugly \
               gstreamer-plugins-bad gstreamer-plugins-bad-free gstreamer-plugins-bad-nonfree

${DO_INSTALL} vlc

# general tools (rpmfusion)
${DO_INSTALL} unrar

# google chrome
${SUDO} tee /etc/yum.repos.d/google-chrome.repo >/dev/null <<-EOF
[google-chrome]
name=google-chrome - 64-bit
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF

${DO_INSTALL} google-chrome-stable

# dropbox
${SUDO} tee /etc/yum.repos.d/dropbox.repo >/dev/null <<-EOF
[Dropbox]
name=Dropbox Repository
baseurl=http://linux.dropbox.com/fedora/\$releasever/
gpgkey=https://linux.dropbox.com/fedora/rpm-public-key.asc
enabled=1
EOF

${DO_INSTALL} nautilus-dropbox

# system update
${DO_UPDATE}

# enable sshd.service on boot
${SUDO} systemctl enable sshd
${SUDO} systemctl start sshd
