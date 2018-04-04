#!/bin/sh

DISTRO="$(awk -F'=' '/^NAME=/{print$2}' /etc/os-release)"

if [ "$(whoami)" = "root" ]; then
  echo "Please DO NOT execute the script the user who have \`root\` privilege"
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

DO_INSTALL="${SUDO} dnf install -y"
DO_UPDATE="${SUDO} dnf update -y"

# detect current running user
if [ -n "${SUDO_USER}" ]; then
  HOMEDIR="$(eval echo ~"${SUDO_USER}")"
else
  HOMEDIR="${HOME}"
fi

EXTENSION_BASE="${HOMEDIR}/.local/share/gnome-shell/extensions"

setupconfig() {
  if diff "${1}" "${2}" >/dev/null; then
    rm -f "${2}.bak"
    return
  fi

  if [ -f "${2}" ]; then
    cp "${2}" "${2}.bak"
  fi
  cp "${1}" "${2}"
}

setup_extension() {
  gnome-shell-extension-tool -d ${2} || true
  rm -rf ${EXTENSION_BASE}/${2}
  git clone https://github.com/${1} ${EXTENSION_BASE}/${2}
  gnome-shell-extension-tool -e ${2} || true
  echo
}

setupconfig bash.bashrc       "${HOMEDIR}/.bashrc"
setupconfig bash.bash_profile "${HOMEDIR}/.bash_profile"
setupconfig vim.vimrc         "${HOMEDIR}/.vimrc"

# ssh config
mkdir -p "${HOMEDIR}/.ssh"
if [ -f "${HOMEDIR}/.ssh/config" ]; then
  awk '
    /^Host \*$/ || /^$/ { show=0 }
    /^Host [a-zA-z0-9][a-zA-z0-9\-]+/ { show=1 }
    show { print }
  ' "${HOMEDIR}/.ssh/config" | tee "${HOMEDIR}/.ssh/config.bak" >/dev/null
fi
cat > "${HOMEDIR}/.ssh/config" <<-EOF
Host *
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  ServerAliveInterval 60
  UseRoaming no
  # UseKeychain yes
  LogLevel quiet
EOF
cat "${HOMEDIR}/.ssh/config.bak" | tee -a "${HOMEDIR}/.ssh/config" >/dev/null
sed -i -e '2,$s/^Host /\nHost /g' "${HOMEDIR}/.ssh/config"
chmod 0640 "${HOMEDIR}/.ssh/config"

# ensure we are running with latest dnf
${DO_UPDATE} dnf

# ssh services
${DO_INSTALL} openssh-clients
${DO_INSTALL} openssh-server

# security upgrade for heartbleed and shellshock
${DO_INSTALL} bash openssl

# develop tools
${DO_INSTALL} git tig git-extras
${DO_INSTALL} curl colordiff meld vim wget
${DO_INSTALL} ethtool htop iftop iperf tcpdump fping
${DO_INSTALL} ShellCheck jq

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
if ! rpm -qa | grep -q "rpmfusion-free-release"; then
  ${DO_INSTALL} "http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm"
fi

if ! rpm -qa | grep -q "rpmfusion-nonfree-release"; then
  ${DO_INSTALL} "http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm"
fi

${DO_INSTALL} ffmpeg gstreamer gstreamer-ffmpeg \
               gstreamer-plugins-base gstreamer-plugins-good gstreamer-plugins-ugly \
               gstreamer-plugins-bad gstreamer-plugins-bad-free gstreamer-plugins-bad-nonfree

${DO_INSTALL} vlc

# general tools (rpmfusion)
${DO_INSTALL} unrar

# virtualbox
${DO_INSTALL} VirtualBox

# vagrant
VAGRANT_VERSION="2.0.3"
if ! rpm -qa | grep -q "vagrant-${VAGRANT_VERSION}"; then
  ${DO_INSTALL} https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.rpm
fi

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

# dropbox (rpmfusion-nonfree)
${DO_INSTALL} nautilus-dropbox

# ruby
${DO_INSTALL} rubygems ruby-devel

# docker
${DO_INSTALL} docker docker-compose docker-vim

# allow current user to run docker with sudo (absolute path)
${SUDO} tee /etc/sudoers.d/docker >/dev/null <<-EOF
# allow current user to run docker with sudo (absolute path)
${USER} ALL=(ALL) NOPASSWD: /usr/bin/docker
${USER} ALL=(ALL) NOPASSWD: /usr/bin/docker-compose
${USER} ALL=(ALL) NOPASSWD: /usr/local/bin/docker-compose
EOF

# gnome-shell-extension
${DO_INSTALL} gnome-shell-extension-apps-menu                                 \
              gnome-shell-extension-panel-osd                                 \
              gnome-shell-extension-user-theme                                \
              gnome-shell-extension-places-menu                               \
              gnome-shell-extension-window-list                               \
              gnome-shell-extension-alternate-tab                             \
              gnome-shell-extension-topicons-plus                             \
              gnome-shell-extension-launch-new-instance                       \
              gnome-shell-extension-do-not-disturb-button                     \
              gnome-shell-extension-activities-configurator                   \
              gnome-shell-extension-screenshot-window-sizer

# https://extensions.gnome.org/extension/690/easyscreencast/
setup_extension EasyScreenCast/EasyScreenCast                                 \
                EasyScreenCast@iacopodeenosee.gmail.com

# https://extensions.gnome.org/extension/779/clipboard-indicator/
setup_extension Tudmotu/gnome-shell-extension-clipboard-indicator             \
                clipboard-indicator@tudmotu.com

# https://extensions.gnome.org/extension/72/recent-items/
setup_extension bananenfisch/RecentItems                                      \
                RecentItems@bananenfisch.net

# https://extensions.gnome.org/extension/517/caffeine/
setup_extension eonpatapon/gnome-shell-extension-caffeine                     \
                caffeine@patapon.info

# https://extensions.gnome.org/extension/104/netspeed/
setup_extension hedayaty/NetSpeed                                             \
                netspeed@hedayaty.gmail.com

# https://extensions.gnome.org/extension/1073/transparent-osd/
setup_extension ipaq3870/gsext-transparent-osd                                \
                transparentosd@ipaq3870

# special workaround for gsext-transparent-osd
cp -rf ${EXTENSION_BASE}/transparentosd@ipaq3870/transparentosd@ipaq3870/     \
       ${EXTENSION_BASE}/transparentosd@ipaq3870/

# font setup for vim-airline
mkdir -p ${HOMEDIR}/.local/share/fonts/
wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
mv PowerlineSymbols.otf ${HOMEDIR}/.local/share/fonts/

mkdir -p ${HOMEDIR}/.config/fontconfig/conf.d/
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
mv 10-powerline-symbols.conf ${HOMEDIR}/.config/fontconfig/conf.d/

fc-cache -vf ${HOMEDIR}/.local/share/fonts/

# system update
${DO_UPDATE}

# enable sshd.service on boot
${SUDO} systemctl enable sshd
${SUDO} systemctl start sshd
