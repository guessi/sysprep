#!/bin/sh

USER_NAME="guessi"
USER_EMAIL="guessi@gmail.com"

WORK_NAME=""
WORK_EMAIL=""

# git global settings
git config --global --bool color.status true
git config --global --bool color.ui true
git config --global --bool log.decorate true
git config --global --bool merge.ff true

git config --global alias.dc 'diff --cached'
git config --global alias.dcs 'diff --cached --stat'
git config --global alias.ds 'diff --stat'
git config --global alias.find '!git ls-files | grep -i'
git config --global alias.hist 'log --pretty=format:"%C(yellow)%h%C(reset) %C(dim green)%ad%C(reset) %s%C(red)%d%C(reset) [%C(cyan)%an%C(reset)]" --graph --date=short'
git config --global alias.lo 'log --oneline --decorate'
git config --global alias.lt '!git describe --tags --abbrev=0 2>/dev/null || echo "not tag defined"'
git config --global alias.ss 'show --stat'
git config --global alias.st 'status -s'

git config --global core.editor vim
git config --global core.pager 'less -F -X'
git config --global diff.tool colordiff
git config --global init.defaultBranch master
git config --global log.date rfc-local
git config --global pull.rebase false
git config --global push.default simple

# go go go: https://golang.org/doc/faq#git_https
git config --global url."ssh://git@github.com/".insteadOf "https://github.com/"

# setup user info
if [ -z "$(git config --global --get user.name)" ] || \
   [ -z "$(git config --global --get user.email)" ]; then
  git config --global user.name "${USER_NAME}"
  git config --global user.email "${USER_EMAIL}"
fi

# github specific configs
git config --global includeIf."gitdir:~/github/".path ~/.gitconfig-github
git config --global includeIf."gitdir:~/go/src/github.com/".path ~/.gitconfig-github

git config -f ~/.gitconfig-github user.name "${USER_NAME}"
git config -f ~/.gitconfig-github user.email "${USER_EMAIL}"

# work specific configs
git config --global includeIf."gitdir:~/work/".path ~/.gitconfig-work

git config -f ~/.gitconfig-work user.name "${WORK_NAME}"
git config -f ~/.gitconfig-work user.email "${WORK_EMAIL}"
