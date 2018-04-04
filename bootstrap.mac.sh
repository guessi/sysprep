#!/bin/sh

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

setupconfig() {
  show_stage "Setup config: ${1}"
  if diff "${1}" "${2}" >/dev/null; then
    rm -f "${2}.bak"
    echo "Skip"
    return
  fi

  if [ -f "${2}" ]; then
    cp "${2}" "${2}.bak"
  fi
  cp "${1}" "${2}"
  echo "Done"
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
  # UseRoaming no
  UseKeychain yes
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

show_stage "Loading packages from Brewfile"
brew bundle

show_stage "Checking for remaining updates"
brew bundle check

show_stage "Cache cleanup"
brew cleanup
brew cask cleanup

show_stage "All jobs done!!!"
