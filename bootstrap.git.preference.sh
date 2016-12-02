#!/bin/sh

# git global settings
git config --global diff.tool colordiff
git config --global core.editor vim
git config --global color.ui true
git config --global color.status true
git config --global alias.ci commit
git config --global alias.co checkout
git config --global alias.d 'diff'
git config --global alias.dc 'diff --cached'
git config --global alias.find '!git ls-files | grep -i'
git config --global alias.hist 'log --pretty=format:"%C(yellow)%h%C(reset) %C(dim green)%ad%C(reset) %s%C(red)%d%C(reset) [%C(cyan)%an%C(reset)]" --graph --date=short'
git config --global alias.lo 'log --oneline --decorate'
git config --global alias.lt '!git describe --tags --abbrev=0 2>/dev/null || echo "not tag defined"'
git config --global alias.st 'status -s'
git config --global log.decorate true
git config --global merge.ff true
git config --global push.default simple
