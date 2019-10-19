# .bashrc

# define GOPATH
export GOPATH=$HOME/go
export GOROOT=/usr/local/go

# define PYENV
export PYENV_ROOT="$HOME/.pyenv"

# setup PATH
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Source z jump definitions
if [ -f ${HOME}/.zjump ]; then
  . ${HOME}/.zjump
fi

# OS type detection
if [ "$(uname -s)" = "Darwin" ]; then
  # setup $PATH for macOS
  export PATH=/usr/local/bin:/usr/local/munki:$PATH
  OS_TYPE="Darwin"
elif [ "$(uname -s)" = "Linux" ]; then
  OS_TYPE="Linux"
else
  OS_TYPE=
fi

OS_ARCH=$(echo ${OS_TYPE} | tr '[A-Z]' '[a-z]')

if [ -n "$(which brew 2>/dev/null)" ]; then
  if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
    . $(brew --prefix)/etc/bash_completion

    if [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]; then
      . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
    fi

    if [ -f "$(brew --prefix)/etc/bash_completion.d/git-prompt.sh" ]; then
      . $(brew --prefix)/etc/bash_completion.d/git-prompt.sh
      git_prompt_support="yes"
    fi
  fi
fi

if [ "${OS_TYPE}" = "Linux" ]; then
  # create symbolic link manually
  # ln -s /usr/share/git-core/contrib/completion/git-prompt.sh /etc/profile.d/
  if [ -f "/etc/profile.d/git-prompt.sh" ]; then
    . /etc/profile.d/git-prompt.sh
    git_prompt_support="yes"
  fi
fi

if [ "${git_prompt_support}" = "yes" ]; then
  GIT_PS1_SHOWDIRTYSTATE=true
  PS1='$(__git_ps1 "(%s) ")\[\e[1;33m\]\u\[\e[0m\]@\[\e[1;35m\]\h\[\e[0m\]:\[\e[1;36m\]\W\[\e[0m\]\$ '
else
  PS1='\[\e[1;33m\]\u\[\e[0m\]@\[\e[1;35m\]\h\[\e[0m\]:\[\e[1;36m\]\W\[\e[0m\]\$ '
fi

# pidgin-sipe
export NSS_SSL_CBC_RANDOM_IV=0

# svn
export SVN_EDITOR='vim'

# history
HISTTIMEFORMAT='%F %T '

# aliases
alias cp='cp -i'
alias df='df -kTh'
alias diff='colordiff'
alias du='du -kh'
alias fd='find . -type d -name'
alias ff='find . -type f -name'
alias g='git'
alias h='history'
alias j='jobs -l'
alias ll='ls -l'
alias ls='ls -F'
alias mv='mv -i'
alias rm='rm -i'
alias vi='vim'

# secure docker under linux system

if [ "${OS_TYPE}" = "Linux" ]; then
  alias docker='sudo docker'
  alias docker-compose='sudo docker-compose'
fi

# docker

alias dockercontainercleanup='docker container prune --force; docker volume prune --force; docker network prune --force'
alias dockerimagecleanup='docker image prune --force'

unalias dockerimageupdate 2>/dev/null
function dockerimageupdate {
  docker container prune --force
  docker image ls -f dangling=false --format '{{.Repository}}:{{.Tag}}' | grep -v "None" | xargs -n 1 -r docker image pull
  docker image prune --force
}

# golang

function go-setup() {
  local GOVERSION=$1
  local PKG_REMOTE_NAME="go${GOVERSION}.${OS_ARCH}-amd64.tar.gz"
  local PKG_REMOTE_PATH="https://dl.google.com/go/${PKG_REMOTE_NAME}"
  local PKG_OUTPUT_PATH="/tmp/${PKG_REMOTE_NAME}"
  local PKG_EXTRACT_PATH="/tmp/go-${GOVERSION}"
  local PKG_TARGET_PATH="/usr/local/go-${GOVERSION}"

  if [ -z "${GOVERSION}" ]; then
    echo "abort, please specify the version to install."
    return
  fi

  if [ -e "${PKG_TARGET_PATH}" ]; then
    echo "abort, target version already existed."
    echo "try: go-switch ${GOVERSION}"
    return
  fi

  if [ ! -f "${PKG_OUTPUT_PATH}" ]; then
    wget ${PKG_REMOTE_PATH} -O ${PKG_OUTPUT_PATH}
  fi

  rm -rf ${PKG_EXTRACT_PATH}
  mkdir -p ${PKG_EXTRACT_PATH}
  tar xf ${PKG_OUTPUT_PATH} --strip-components 1 -C ${PKG_EXTRACT_PATH}

  sudo rm -rf ${PKG_TARGET_PATH}
  sudo mv ${PKG_EXTRACT_PATH} ${PKG_TARGET_PATH}

  go-switch ${GOVERSION}
}

function go-switch() {
  local GOVERSION=$1

  if [ -z "${GOVERSION}" ]; then
    find /usr/local -maxdepth 1 -type d -name "go*"
    return
  fi

  if [ ! -d "/usr/local/go-${GOVERSION}" ]; then
    return
  fi
  sudo rm -f /usr/local/go
  sudo ln -s -f /usr/local/go-${GOVERSION} /usr/local/go

  go version
}

# misc

function ssl_certs_check() {
  echo | openssl s_client -servername $1 -connect $1:443 2>/dev/null | openssl x509 -noout -dates
}

function sync-git-folders() {
  for dir in $(find . -type d -depth 1 -name ".git"); do
    pushd $(dirname $dir)
      git checkout master
      git fetch -apP origin
      git fetch -apP --tags origin
      git pull
    popd
  done
}

function cleanup_history() {
  rm -rf ~/.oracle_jre_usage
  rm -rf ~/.terraform.d/checkpoint_*
  # rm -rf ~/.kube
  # rm -rf ~/.config/gcloud
  rm -rf ~/.DS_Store
  rm -rf ~/.calc_history
  rm -rf ~/.httpie
  rm -rf ~/.lesshst
  rm -rf ~/.rediscli_history
  rm -rf ~/.wget-hsts
  rm -rf ~/.python_history
  rm -rf ~/.z
  rm -rf ~/.bash_history
  rm -rf ~/.config/gcloud/logs

  find ~/.vagrant.d/boxes -type d -exec rmdir {} \; 2>/dev/null
}

# custom aliases
if [ -f "~/.bash_aliases" ]; then
  . ~/.bash_aliases
fi

# define your extra configuration in ~/.zshrc.extra
if [ -f ~/.bashrc.extra ]; then
  source ~/.bashrc.extra
fi
