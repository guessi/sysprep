#!/bin/sh

DISTRO="$(awk -F'=' '/^NAME=/{print$2}' /etc/os-release)"
FEDORA_VERSION=$(awk -F'=' '/^VERSION_ID/{print$2}' /etc/os-release)

if [ "$(whoami)" = "root" ]; then
  echo "Please DO NOT execute the script the user who have \`root\` privilege"
  exit 1
fi

if ! echo "${DISTRO}" | grep -i -q "Fedora"; then
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

${DO_INSTALL} dnf-plugins-core

${SUDO} dnf config-manager --add-repo \
  https://rpm.releases.hashicorp.com/fedora/hashicorp.repo

${SUDO} tee /etc/yum.repos.d/google-chrome.repo >/dev/null <<-EOF
[google-chrome]
name=google-chrome - 64-bit
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
EOF

if ! rpm -qa | grep -q "rpmfusion-free-release"; then
  ${DO_INSTALL} "http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm"
fi

if ! rpm -qa | grep -q "rpmfusion-nonfree-release"; then
  ${DO_INSTALL} "http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm"
fi

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

setupconfig bash.bashrc         "${HOMEDIR}/.bashrc"
setupconfig bash.bashrc.aliases "${HOMEDIR}/.bashrc.aliases"
setupconfig bash.bash_profile   "${HOMEDIR}/.bash_profile"
setupconfig vim.vimrc           "${HOMEDIR}/.vimrc"
setupconfig tig.tigrc           "${HOMEDIR}/.tigrc"
setupconfig zsh.zshrc           "${HOMEDIR}/.zshrc"
setupconfig zsh.zshrc.aliases   "${HOMEDIR}/.zshrc.aliases"

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
${DO_UPDATE}                                                                  \
  dnf                                                                         \
  dnf-plugins-core                                                            \
  openssh-clients                                                             \
  openssh-server

# developer tools
${DO_INSTALL}                                                                 \
  ShellCheck                                                                  \
  ack                                                                         \
  awscli                                                                      \
  bash                                                                        \
  colordiff                                                                   \
  curl                                                                        \
  ethtool                                                                     \
  fping                                                                       \
  git                                                                         \
  git-extras                                                                  \
  htop                                                                        \
  iftop                                                                       \
  iperf                                                                       \
  jq                                                                          \
  keepassxc                                                                   \
  libcurl                                                                     \
  meld                                                                        \
  openssl                                                                     \
  p7zip                                                                       \
  p7zip-plugins                                                               \
  ripgrep                                                                     \
  ruby-devel                                                                  \
  rubygems                                                                    \
  tcpdump                                                                     \
  tig                                                                         \
  unrar                                                                       \
  unzip                                                                       \
  vim                                                                         \
  wget                                                                        \
  zsh

# general setup
${DO_INSTALL}                                                                 \
  hexchat                                                                     \
  ibus-chewing                                                                \
  pcmanx-gtk2                                                                 \
  google-noto-sans-cjk-ttc-fonts                                              \
  google-noto-serif-cjk-ttc-fonts                                             \
  google-noto-fonts-common                                                    \
  google-noto-cjk-fonts-common                                                \
  google-noto-emoji-color-fonts                                               \
  google-noto-sans-sinhala-fonts                                              \
  google-droid-sans-fonts                                                     \
  google-droid-sans-mono-fonts                                                \
  wqy-microhei-fonts                                                          \
  wqy-zenhei-fonts

# create link for git-prompt.sh
if [ -f /etc/profile.d/git-prompt.sh ] || [ -L /etc/profile.d/git-prompt.sh ]; then
  ${SUDO} rm -vf /etc/profile.d/git-prompt.sh
fi

if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
  ${SUDO} ln -s -f /usr/share/git-core/contrib/completion/git-prompt.sh /etc/profile.d/
fi

# setup z jump
curl https://raw.githubusercontent.com/rupa/z/master/z.sh > ${HOMEDIR}/.zjump

# gnome toolkits
${DO_INSTALL}                                                                 \
  dconf-editor                                                                \
  gnome-shell-extension-user-theme                                            \
  gnome-tweak-tool                                                            \
  gnome-nettool                                                               \
  nautilus-open-terminal

gsettings set org.gnome.shell always-show-log-out true

${DO_INSTALL}                                                                 \
  alsa-plugins-pulseaudio                                                     \
  ffmpeg                                                                      \
  vlc

${DO_INSTALL}                                                                 \
  gstreamer1                                                                  \
  gstreamer1-plugins-bad-free                                                 \
  gstreamer1-plugins-base                                                     \
  gstreamer1-plugins-good                                                     \
  gstreamer1-plugins-ugly                                                     \
  gstreamer1-plugins-ugly-free

# virtualbox
${DO_INSTALL} VirtualBox

# vagrant
${DO_INSTALL} vagrant

${DO_INSTALL} google-chrome-stable

# dropbox (rpmfusion-nonfree)
${DO_INSTALL} nautilus-dropbox

# gnome-shell-extension
${DO_INSTALL}                                                                 \
  gnome-shell-extension-caffeine                                              \
  gnome-shell-extension-do-not-disturb-button                                 \
  gnome-shell-extension-launch-new-instance                                   \
  gnome-shell-extension-netspeed                                              \
  gnome-shell-extension-topicons-plus                                         \
  gnome-shell-extension-user-theme

# font setup for vim-airline
# reference:
# - https://powerline.readthedocs.io/en/latest/installation.html#fonts-installation
mkdir -p ${HOMEDIR}/.local/share/fonts/
wget https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf
mv PowerlineSymbols.otf ${HOMEDIR}/.local/share/fonts/

mkdir -p ${HOMEDIR}/.config/fontconfig/conf.d/
wget https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf
mv 10-powerline-symbols.conf ${HOMEDIR}/.config/fontconfig/conf.d/

fc-cache -vf ${HOMEDIR}/.local/share/fonts/

# setup antigen
if [ -d ~/.antigen ]; then
  pushd ~/.antigen
    git checkout master
    git fetch origin master
    git reset --hard origin/master
  popd
else
  git clone https://github.com/zsh-users/antigen.git ~/.antigen
fi

# system update
${DO_UPDATE}

# enable sshd.service on boot
${SUDO} systemctl enable sshd
${SUDO} systemctl start sshd
