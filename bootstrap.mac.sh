#!/bin/bash

#
# Bootstrap script for macOS
#

show_stage() {
  echo
  [ -z "$1" ] && return
  echo "$(tput setaf 4)==>$(tput sgr0) $(tput bold)${1}$(tput sgr0)"
}

if [ "$(whoami)" = "root" ]; then
  echo "Please DO NOT execute the script the user who have \`root\` privilege"
  exit 1
fi

if [ "$(uname -s)" != "Darwin" ]; then
  show_stage "Abort, it is design for macOS only"
  exit 1
fi

show_stage "Environment"
sw_vers

HOMEDIR="${HOME}"

# bashrc
if [ -f "${HOMEDIR}/.bashrc" ]; then
  cp "${HOMEDIR}/.bashrc" "${HOMEDIR}/.bashrc.bak"
fi
cp bash.bashrc "${HOMEDIR}/.bashrc"

# bash_profile
if [ -f "${HOMEDIR}/.bash_profile" ]; then
  cp "${HOMEDIR}/.bash_profile" "${HOMEDIR}/.bash_profile.bak"
fi
cp bash.bashrc "${HOMEDIR}/.bash_profile"

# vimrc
if [ -f "${HOMEDIR}/.vimrc" ]; then
  cp "${HOMEDIR}/.vimrc" "${HOMEDIR}/.vimrc.bak"
fi
cp vim.vimrc "${HOMEDIR}/.vimrc"

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
  # UseRoaming no
  LogLevel quiet
EOF
cat "${HOMEDIR}/.ssh/config.bak" | tee -a "${HOMEDIR}/.ssh/config" >/dev/null
sed -i -e '2,$s/^Host /\'$'\nHost /g' "${HOMEDIR}/.ssh/config"
chmod 0640 "${HOMEDIR}/.ssh/config"

if [ -z "$(which ruby)" ]; then
  show_stage "ruby: command not found, aborting"
  exit 1
fi

show_stage "Checking for Homebrew existence"
if [ -z "$(which brew)" ]; then
  HOMEBREW="https://raw.githubusercontent.com/Homebrew/install/master/install"
  ruby -e "$(curl -fsSL ${HOMEBREW})"
fi

show_stage "Cheking updates for Homebrew"
brew update
brew update # yes, run it again

if [ ! -f "$(pwd)/Brewfile" ]; then
  show_stage "Skip, Brewfile not found"
else
  show_stage "Brewfile found (backup: Brewfile.orig)"
  cp -vf Brewfile Brewfile.orig
fi

show_stage "Loading packages from Brewfile"
brew bundle

show_stage "Checking for remaining updates"
brew bundle check

show_stage "Cache cleanup"
brew cleanup
brew cask cleanup

if [ -z "$(git config --get user.name)" ]; then
  show_stage "Warning, git config 'user.name' not set"
fi

if [ -z "$(git config --get user.email)" ]; then
  show_stage "Warning, git config 'user.email' not set"
fi

show_stage "All jobs done!!!"
