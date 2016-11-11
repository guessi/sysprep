#!/bin/bash

#
# Bootstrap script for macOS
#

show_stage() {
  echo
  [ -z "$1" ] && return
  echo "$(tput setaf 4)==>$(tput sgr0) $(tput bold)${1}$(tput sgr0)"
}

if [ "$(uname -s)" != "Darwin" ]; then
  show_stage "Abort, it is design for macOS only"
  exit 1
fi

show_stage "Environment"
sw_vers

if [ -z "$(which ruby)" ]; then
  show_stage "ruby: command not found, aborting"
  exit 1
fi

show_stage "Checking for Homebrew existence"
if [ -z “$(which brew)” ]; then
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
