# define GOPATH
export GOPATH=$HOME/go
# export GOROOT=/usr/local/opt/go/libexec # go package from `brew install golang`
export GOROOT=/usr/local/go
export GOPROXY=direct

# set default AWS profile
export AWS_PROFILE=admin

# If you come from bash you might have to change your $PATH.
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/curl/bin:$PATH"
export PATH="/usr/local/opt/mysql-client@5.7/bin:$PATH"
export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
export PATH="$HOME/.krew/bin:$PATH"
export PATH="$HOME/.toolbox/bin:$PATH"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# disable auto update (manual update: upgrade_oh_my_zsh)
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true

# setup gcloud auto complete
if [ -d '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk' ]; then
  source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
  source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
fi

if [ -d ~/google-cloud-sdk ]; then
  source ~/google-cloud-sdk/completion.zsh.inc
  source ~/google-cloud-sdk/path.zsh.inc
fi

# setup nvm
export NVM_DIR="$HOME/.nvm"

if [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
  source "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
fi

if [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ]; then
  source "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
fi

# history
export HIST_STAMPS="yyyy-mm-dd"
export HISTFILE=~/.zsh_history
export HISTSIZE=25000
export SAVEHIST=10000

# antigen
source ~/.antigen/antigen.zsh

antigen use oh-my-zsh
antigen theme fishy

antigen bundles << BUNDLES
  aws
  colored-man-pages
  command-not-found
  docker
  pip
  screen
  terraform
  vagrant
  z

  mattberther/zsh-pyenv

  zsh-users/zsh-completions
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-syntax-highlighting
BUNDLES

antigen apply

# User configuration
unsetopt beep

function prompt-context() {
  # HINT: uncomment this for enabling prompt detection
  return

  if [ ! -d "${HOME}/.config/gcloud" ] || \
     [ ! -f "${HOME}/.config/gcloud/active_config" ]; then
    return
  fi

  local ACTIVE_CONFIG="$(cat ~/.config/gcloud/active_config)"
  local CONFIGURATION="${HOME}/.config/gcloud/configurations/config_${ACTIVE_CONFIG}"
  if [ ! -f "${CONFIGURATION}" ]; then
      return
  fi

  CONTEXT=$(cat ${CONFIGURATION} | awk -F'=' '/^(project|cluster)/{print $2}' | xargs | sed -e 's/ /] [/' 2>/dev/null) && \
    (
      printf "[${CONTEXT}] "
    )
}

PROMPT='%{$fg[yellow]%}$(prompt-context)%{$reset_color%}%{$fg[blue]%}%n%{$reset_color%}:%{$fg[green]%}$(_fishy_collapsed_wd)%{$reset_color%}$(git_prompt_info)$(git_prompt_status) %# %{$reset_color%}'
RPROMPT=''

alias cp='cp -i'
alias df='df -kTh'
alias diff='colordiff'
alias du='du -kh'
alias g='git'
alias h='history'
alias ll='ls -l'
alias ls='ls -F'
alias mv='mv -i'
alias rm='rm -i'
alias vi='vim'
alias md5='md5 -r'
alias watch='watch '
alias tree='tree -aFI .git'

alias pycodestyle='pycodestyle --ignore=E501'

# docker

alias dockercontainercleanup='docker container prune --force; docker volume prune --force; docker network prune --force'
alias dockerimagecleanup='docker image prune --force'

unalias dockerimageupdate 2>/dev/null
function dockerimageupdate {
  docker container prune --force
  docker image ls -f dangling=false --format '{{.Repository}}:{{.Tag}}' | grep -v "None" | xargs -n 1 docker image pull
  docker image prune --force
}

function switch-project() {
  gcloud config set project $1
  gcloud config set compute/region $2
  gcloud config set compute/zone $3
}

function switch-cluster() {
  switch-project $1 $2 $3
  gcloud config set container/cluster $4
  gcloud container clusters get-credentials --region $2 $4 2>/dev/null || \
  gcloud container clusters get-credentials --zone   $3 $4 2>/dev/null
}

# kubernetes

if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi

if [ $commands[helm] ]; then
  source <(helm completion zsh)
fi

# kubernetes shortcuts

alias k='kubectl'
alias kd='kubectl describe'
alias kg='kubectl get'
alias kgowide='kubectl get -o=wide'
alias kgoyaml='kubectl get -o=yaml'
alias klo='kubectl logs -f'
alias kpf='kubectl port-forward'
alias krm='kubectl delete'
alias kex='kubectl exec -i -t'

alias kgn='kubectl get nodes'
alias kgnw='kubectl get nodes -o wide'
alias kgna='kubectl get nodes --label-columns=node.kubernetes.io/instance-type,topology.kubernetes.io/zone,eks.amazonaws.com/capacityType,karpenter.sh/capacity-type,eks.amazonaws.com/nodegroup'

alias kgp='kubectl get pods'
alias kgpw='kubectl get pods -o wide'
alias kgpa='kubectl get pods -o wide --all-namespaces'
alias kgpas='kubectl get pods -o wide --all-namespaces --sort-by spec.nodeName'

alias kgd='kubectl get deployment'
alias kgds='kubectl get daemonsets'
alias kgi='kubectl get ingress'
alias kgs='kubectl get service'
alias kgsts='kubectl get statefulsets'

# kubernetes shortcuts (plugins required)

alias krc='kubectl resource_capacity'
alias krcp='kubectl resource_capacity -p'

# golang

function go-setup() {
  local GOVERSION=$1
  local FORCE=$2
  local PKG_REMOTE_PATH="https://go.dev/dl/go${GOVERSION}.darwin-amd64.tar.gz"
  local PKG_OUTPUT_PATH="/tmp/go${GOVERSION}.darwin-amd64.tar.gz"
  local PKG_EXTRACT_PATH="/tmp/go-${GOVERSION}"
  local PKG_TARGET_PATH="/usr/local/go-${GOVERSION}"

  if [ -z "${GOVERSION}" ]; then
    echo "abort, please specify the version to install."
    return
  fi

  if [ -e "${PKG_TARGET_PATH}" ]; then
    if [ "${FORCE}" != "force" ]; then
      echo "abort, target version already existed."
      return
    fi
    rm -f ${PKG_OUTPUT_PATH}
  fi

  if [ ! -f "${PKG_OUTPUT_PATH}" ]; then
    wget ${PKG_REMOTE_PATH} -O ${PKG_OUTPUT_PATH} --no-verbose --show-progress
  fi

  rm -rf ${PKG_EXTRACT_PATH}
  mkdir -p ${PKG_EXTRACT_PATH}
  tar xf ${PKG_OUTPUT_PATH} --strip-components 1 -C ${PKG_EXTRACT_PATH}
  if [ $? -ne 0 ]; then
    rm -rf ${PKG_EXTRACT_PATH}
  else
    echo "Hint: password might be required to finish setup"
    sudo rm -rf ${PKG_TARGET_PATH}
    sudo mv ${PKG_EXTRACT_PATH} ${PKG_TARGET_PATH}

    go-switch ${GOVERSION}
  fi

  rm -f ${PKG_OUTPUT_PATH}
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

  echo "Hint: password might be required to finish setup"
  sudo rm -f /usr/local/go
  sudo ln -s -f /usr/local/go-${GOVERSION} /usr/local/go

  echo "Hint: check version installed"
  go version
}

# aws

function ec2-list-simple() {
  local PROFILE=$1

    aws ec2 describe-instances --output table \
      --query 'Reservations[].Instances[].[Tags[?Key==`Name`] | [0].Value, State.Name, InstanceType, PrivateIpAddress] | sort_by(@, &[0])' \
      --filters 'Name=instance-state-name,Values=running' \
      --profile "${PROFILE}"
}

function ec2-list() {
  local PROFILE=$1

  aws ec2 describe-instances --output table \
    --query 'Reservations[].Instances[].[Tags[?Key==`Name`] | [0].Value, State.Name, InstanceId, InstanceType, PrivateIpAddress, PublicIpAddress] | sort_by(@, &[0])' \
    --filters 'Name=instance-state-name,Values=running' \
    --profile "${PROFILE}"
}

function ec2-ri-info() {
  local PROFILE=$1

  aws ec2 describe-instances --output text \
    --query 'Reservations[].Instances[].[Tags[?Key==`Name`] | [0].Value, InstanceType] | sort_by(@, &[0])' \
    --filters 'Name=instance-state-name,Values=running' \
    --profile "${PROFILE}"
}

# misc

function random_password() {
  bw generate -ulns --length 16
  bw generate -uln  --length 16
  bw generate --words 5 -p
}

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

function remove_color() {
  # https://unix.stackexchange.com/questions/140251/strip-color-on-os-x-with-bsd-sed-or-any-other-tool
  sed -e "s,$(printf '\033')\\[[0-9;]*[a-zA-Z],,g" $1
}

function cleanup_history() {
  rm -rf ~/.DS_Store
  rm -rf ~/.calc_history
  rm -rf ~/.config/gcloud/logs
  rm -rf ~/.httpie
  rm -rf ~/.lesshst
  rm -rf ~/.mysql_history
  rm -rf ~/.oracle_jre_usage
  rm -rf ~/.python_history
  rm -rf ~/.rediscli_history
  rm -rf ~/.sqlite_history
  rm -rf ~/.terraform.d/checkpoint_*
  rm -rf ~/.wget-hsts
  rm -rf ~/.z
  rm -rf ~/.zsh_history
  rm -rf ~/.zshrc.bak
  rm -rf ~/.zshrc.zwc

  find ~/.vagrant.d/boxes -type d -exec rmdir {} \; 2>/dev/null
}

function secure_remove() {
  shred -u -n 9 $@
}

function ip() {
  curl -s ipconfig.io/json | jq .
}

# define your extra configuration in ~/.zshrc.extra
if [ -f ~/.zshrc.extra ]; then
  source ~/.zshrc.extra
fi
