#!/bin/sh

DISTRO="$(awk -F'=' '/^NAME=/{print$2}' /etc/os-release)"

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

if [ -z "$(which dnf)" ]; then
  DO_INSTALL="${SUDO} yum install -y"
  DO_UPDATE="${SUDO} yum update -y"
else
  DO_INSTALL="${SUDO} dnf install -y"
  DO_UPDATE="${SUDO} dnf update -y"
fi

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

# ensure we are running with latest dnf/yum toolkit
if [ -n "$(which dnf)" ]; then
  ${DO_UPDATE} dnf
else
  ${DO_UPDATE} yum
fi

# ssh services
${DO_INSTALL} openssh-clients
${DO_INSTALL} openssh-server

# security upgrade for heartbleed and shellshock
${DO_INSTALL} bash openssl

# develop tools
${DO_INSTALL} git gitg tig
${DO_INSTALL} curl colordiff meld vim wget
${DO_INSTALL} ethtool htop iftop iperf tcpdump

# git global settings
git config --global diff.tool colordiff
git config --global core.editor vim
git config --global color.ui true
git config --global alias.co checkout
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.br branch
git config --global alias.hist 'log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short'
git config --global alias.lo 'log --oneline --decorate'
git config --global push.default simple

# create link for git-prompt.sh
if [ -f /etc/profile.d/git-prompt.sh ] || [ -L /etc/profile.d/git-prompt.sh ]; then
  rm -f /etc/profile.d/git-prompt.sh
fi

if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
  ${SUDO} ln -s -f /usr/share/git-core/contrib/completion/git-prompt.sh /etc/profile.d/
fi

# general tools
${DO_INSTALL} p7zip p7zip-plugins unzip libcurl

# adobe flash plugin
${RPM_INSTALL} http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
${RPM_IMPORT} /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
${DO_INSTALL} flash-plugin

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

# communication
${DO_INSTALL} pidgin pidgin-sipe

# input method
${DO_INSTALL} ibus-chewing

# gnome toolkits
${DO_INSTALL} gnome-tweak-tool dconf-editor
${DO_INSTALL} gnome-shell-extension-alternate-tab
${DO_INSTALL} gnome-shell-extension-pidgin
${DO_INSTALL} gnome-shell-extension-user-theme
${DO_INSTALL} nautilus-open-terminal

# desktop experience
if [ "${OS_VERSION}" -lt 24 ]; then
  ${DO_INSTALL} gnome-shell-theme-zukitwo
fi

gsettings set org.gnome.shell always-show-log-out true

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
enabled=0
EOF

${DO_INSTALL} nautilus-dropbox

# system update
${DO_UPDATE}

# enable sshd.service on boot
systemctl enable sshd
systemctl start sshd
