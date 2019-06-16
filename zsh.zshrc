# define GOPATH
export GOPATH=$HOME/go
# export GOROOT=/usr/local/opt/go/libexec
export GOROOT=/usr/local/go

# If you come from bash you might have to change your $PATH.
export PATH=$GOROOT/bin:$GOPATH/bin:/usr/local/bin:/usr/local/sbin:$HOME/work/tools/arcanist/bin:/usr/local/opt/curl/bin:$PATH

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# disable auto update (manual update: upgrade_oh_my_zsh)
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true

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
alias fd='find . -type d -name'
alias ff='find . -type f -name'
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

alias dockercontainercleanup='docker container prune --force'
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
  node_regular=$(kubectl get no -l cloud.google.com/gke-preemptible!=true 2>/dev/null)
  node_regular_count=$(($(echo $node_regular | wc -l) -1))
  node_preemptible=$(kubectl get no -l cloud.google.com/gke-preemptible=true 2>/dev/null)
  node_preemptible_count=$(($(echo $node_preemptible | wc -l) -1))
  node_total_count=$((node_regular_count + node_preemptible_count))

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
  kubectl $@ get po -o wide | awk '{print$7,$1,$5}' | sort | column -t
}

# misc

function ssl_certs_check() {
  echo | openssl s_client -servername $1 -connect $1:443 2>/dev/null | openssl x509 -noout -dates
}

function sync-git-folders() {
  for dir in $(find . -type d -name ".git"); do pushd $(dirname $dir); git pull; git fetch -p -a; popd; done
}

function cleanup_history() {
  rm -rf ~/.oracle_jre_usage
  rm -rf ~/.terraform.d/checkpoint_*
  rm -rf ~/.kube
  rm -rf ~/.DS_Store
  rm -rf ~/.calc_history
  rm -rf ~/.httpie
  rm -rf ~/.lesshst
  rm -rf ~/.python_history
  rm -rf ~/.z
  rm -rf ~/.zsh_history
  rm -rf ~/.config/gcloud/logs

  find ~/.vagrant.d/boxes -type d -exec rmdir {} \; 2>/dev/null
}

# define your extra configuration in ~/.zshrc.extra
if [ -f ~/.zshrc.extra ]; then
  source ~/.zshrc.extra
fi
