#!/bin/sh

if [ "$(whoami)" = "root" ]; then
  echo "Please DO NOT execute the script the user who have \`root\` privilege"
  exit 1
fi

# Install lsb-release if missing
if ! command -v lsb_release >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y lsb-release
fi

if [ "$(lsb_release -is)" != "Ubuntu" ]; then
  echo "Sorry, this script was written for Ubuntu only"
  exit 1
fi

# Install required tools if missing
for tool in awk diff; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Error: Required tool '$tool' not found"
    exit 1
  fi
done

if [ "$(whoami)" != "root" ]; then
  SUDO='sudo -E'
else
  SUDO=''
fi

DO_INSTALL="${SUDO} apt install -y"
DO_UPGRADE="${SUDO} apt upgrade -y"

# detect current running user
if [ -n "${SUDO_USER}" ]; then
  HOMEDIR="$(eval echo ~"${SUDO_USER}")"
else
  HOMEDIR="${HOME}"
fi

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

setupconfig bash.bash_profile   "${HOMEDIR}/.bash_profile"
setupconfig bash.bashrc         "${HOMEDIR}/.bashrc"
setupconfig bash.bashrc.aliases "${HOMEDIR}/.bashrc.aliases"
setupconfig kubectl.kuberc      "${HOMEDIR}/.kube/kuberc"
setupconfig tig.tigrc           "${HOMEDIR}/.tigrc"
setupconfig vim.vimrc           "${HOMEDIR}/.vimrc"
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
  ServerAliveInterval 60
  LogLevel ERROR
  # StrictHostKeyChecking no
  # UserKnownHostsFile /dev/null
EOF
cat "${HOMEDIR}/.ssh/config.bak" | tee -a "${HOMEDIR}/.ssh/config" >/dev/null
sed -i -e '2,$s/^Host /\nHost /g' "${HOMEDIR}/.ssh/config"
chmod 0640 "${HOMEDIR}/.ssh/config"

# pre-setup
${SUDO} apt update
${DO_INSTALL} git

# ssh services
${DO_INSTALL} openssh-client
${DO_INSTALL} openssh-server

# security upgrade for heartbleed and shellshock
${DO_INSTALL} bash openssl

# develop tools
${DO_INSTALL} git tig git-extras
${DO_INSTALL} curl colordiff meld vim wget ripgrep
${DO_INSTALL} ethtool htop iftop iperf tcpdump fping
${DO_INSTALL} shellcheck jq

# zsh
${DO_INSTALL} zsh

# create link for git-prompt.sh
if [ -f /etc/profile.d/git-prompt.sh ] || [ -L /etc/profile.d/git-prompt.sh ]; then
  ${SUDO} rm -vf /etc/profile.d/git-prompt.sh
fi

if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
  ${SUDO} ln -s -f /usr/share/git-core/contrib/completion/git-prompt.sh /etc/profile.d/
fi

if [ ! -f /etc/profile.d/git-prompt.sh ]; then
  curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh | \
    ${SUDO} tee /etc/profile.d/git-prompt.sh >/dev/null
fi

# setup z jump
curl https://raw.githubusercontent.com/rupa/z/master/z.sh > ${HOMEDIR}/.zjump

# general tools
${DO_INSTALL} p7zip p7zip-full unrar unzip

# chinese fonts
${DO_INSTALL} fonts-wqy-microhei fonts-wqy-zenhei

# input method
${DO_INSTALL} ibus-chewing

# gnome toolkits
${DO_INSTALL} gnome-tweak-tool dconf-editor
${DO_INSTALL} gnome-shell-extensions
${DO_INSTALL} gnome-shell-extension-caffeine

# ruby
${DO_INSTALL} ruby ruby-dev rubygems-integration

# multimedia
${DO_INSTALL} ffmpeg \
  gstreamer1.0-plugins-bad \
  gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-ugly

# vlc
${DO_INSTALL} vlc

# apt upgrade
${DO_UPGRADE}
