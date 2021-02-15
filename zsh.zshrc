# define GOPATH
export GOPATH=$HOME/go
# export GOROOT=/usr/local/opt/go/libexec # go package from `brew install golang`
export GOROOT=/usr/local/go

# If you come from bash you might have to change your $PATH.
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/curl-openssl/bin:$PATH"
export PATH="/usr/local/opt/mysql-client@5.7/bin:$PATH"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
export PATH="$HOME/.krew/bin:$PATH"

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
  zsh_reload

  mattberther/zsh-pyenv

  zsh-users/zsh-completions
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-syntax-highlighting
BUNDLES

antigen apply

# User configuration
unsetopt beep

function prompt-context() {
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
alias watch="watch "

# docker

alias dockercontainercleanup='docker container prune --force; docker volume prune --force; docker network prune --force'
alias dockerimagecleanup='docker image prune --force'

unalias dockerimageupdate 2>/dev/null
function dockerimageupdate {
  docker container prune --force
  docker image ls -f dangling=false --format '{{.Repository}}:{{.Tag}}' | grep -v "None" | xargs -n 1 docker image pull
  docker image prune --force
}

# google cloud platform

function gcloud_completion() {
  # workaround for loading completion for google-cloud-sdk
  source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
  source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
}

function find-load-balancer-by-ip() {
  if [ $# -eq 1 ]; then
    gcloud compute forwarding-rules list --filter IPAddress=$1
  fi
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

function get-node-by-type() {
  local node_regular=$(kubectl get no -l cloud.google.com/gke-preemptible!=true 2>/dev/null)
  local node_regular_count=$(($(echo $node_regular | wc -l) -1))
  local node_preemptible=$(kubectl get no -l cloud.google.com/gke-preemptible=true 2>/dev/null)
  local node_preemptible_count=$(($(echo $node_preemptible | wc -l) -1))
  local node_total_count=$((node_regular_count + node_preemptible_count))

  if [ $node_regular_count -gt 0 ]; then
    echo "==> Node Type: regular (Count: $node_regular_count)"
    echo
    echo $node_regular
    echo
  fi

  if [ $node_preemptible_count -gt 0 ]; then
    echo "==> Node Type: preemptible (Count: $node_preemptible_count)"
    echo
    echo $node_preemptible
    echo
  fi

  echo "==> Regular Node: $node_regular_count"
  echo "==> Preemptible Node: $node_preemptible_count"
  echo
  echo "==> Total Node: $node_total_count"
}

function get-all() {
  kubectl get hpa,deploy,po,svc,ing,statefulsets,pvc,pv $@
}

function get-pod-by-node() {
  if [ x"$1" = x"--all-namespaces" ]; then
    kubectl get po $@ -o wide | awk '{print$8,$2,$6}' | sort | column -t
  else
    kubectl get po $@ -o wide | awk '{print$7,$1,$5}' | sort | column -t
  fi
}

function set-hpa() {
  if [ $# -ne 4 ]; then
    echo "invalid input"
    return
  fi

  kubectl -n $1 patch hpa $2 --patch '{"spec":{"minReplicas":'$3',"maxReplicas":'$4'}}'
}

# golang

function go-setup() {
  local GOVERSION=$1
  local PKG_REMOTE_PATH="https://dl.google.com/go/go${GOVERSION}.darwin-amd64.tar.gz"
  local PKG_OUTPUT_PATH="/tmp/go${GOVERSION}.darwin-amd64.tar.gz"
  local PKG_EXTRACT_PATH="/tmp/go-${GOVERSION}"
  local PKG_TARGET_PATH="/usr/local/go-${GOVERSION}"

  if [ -z "${GOVERSION}" ]; then
    echo "abort, please specify the version to install."
    return
  fi

  if [ -e "${PKG_TARGET_PATH}" ]; then
    echo "abort, target version already existed."
    return
  fi

  if [ ! -f "${PKG_OUTPUT_PATH}" ]; then
    wget ${PKG_REMOTE_PATH} -O ${PKG_OUTPUT_PATH}
  fi

  rm -rf ${PKG_EXTRACT_PATH}
  mkdir -p ${PKG_EXTRACT_PATH}
  tar xf ${PKG_OUTPUT_PATH} --strip-components 1 -C ${PKG_EXTRACT_PATH}
  if [ $? -ne 0 ]; then
    rm -rf ${PKG_EXTRACT_PATH}
  else
    sudo rm -rf ${PKG_TARGET_PATH}
    sudo mv ${PKG_EXTRACT_PATH} ${PKG_TARGET_PATH}

    go-switch ${GOVERSION}
  fi
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
  # rm -rf ~/.config/gcloud
  # rm -rf ~/.kube
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

  find ~/.vagrant.d/boxes -type d -exec rmdir {} \; 2>/dev/null
}

function secure_remove() {
  shred -u -n 9 $@
}

# define your extra configuration in ~/.zshrc.extra
if [ -f ~/.zshrc.extra ]; then
  source ~/.zshrc.extra
fi

function gam() {
  "${HOME}/bin/gam/gam" "$@"
}
