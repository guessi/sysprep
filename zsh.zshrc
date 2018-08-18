# define GOPATH
export GOPATH=$HOME/go

# If you come from bash you might have to change your $PATH.
export PATH=$GOPATH/bin:$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/local/opt/curl/bin:$HOME/work/tools/arcanist/bin:$PATH

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# disable auto update (manual update: upgrade_oh_my_zsh)
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true

# history
export HIST_STAMPS="yyyy-mm-dd"
export HISTIGNORE="&:ls:bg:fg:exit:clear:cd"
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
  sudo
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

function kube-context {
  if [ ! -d "${HOME}/.kube" ]; then
    return
  fi
  CONTEXT=$(command kubectl config current-context 2>/dev/null) && \
    (
      # printf "[$(echo ${CONTEXT} | cut -d_ -f2)]"
      # printf "[$(echo ${CONTEXT} | cut -d_ -f3)]"
      printf "[$(echo ${CONTEXT} | cut -d_ -f4)] "
    )
}

PROMPT='%{$fg[yellow]%}$(kube-context)%{$reset_color%}%{$fg[blue]%}%n%{$reset_color%}:%{$fg[$user_color]%}$(_fishy_collapsed_wd)%{$reset_color%}$(git_prompt_info)$(git_prompt_status) %# %{$reset_color%}'
RPROMPT=''

alias cp='cp -i'
alias df='df -kTh'
alias diff='colordiff'
alias du='du -kh'
alias fd='find . -type d -name'
alias ff='find . -type f -name'
alias g='git'
alias h='history'
# alias j='job -l'
alias ll='ls -l'
alias ls='ls -F'
alias mv='mv -i'
alias rm='rm -i'
alias vi='vim'
alias md5='md5 -r'

if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi

if [ $commands[helm] ]; then
  source <(helm completion zsh)
fi

alias dockercontainercleanup='docker container prune --force'
alias dockerimagecleanup='docker image prune --force'

unalias dockerimageupdate 2>/dev/null
function dockerimageupdate {
  for image in $(docker images -f dangling=false --format '{{.Repository}}:{{.Tag}}' | grep -v "none"); do
    docker pull ${image} || true
  done

  # cleanup after image pull
  dockerimagecleanup
}

function sync-git-folders() {
  for dir in $(find . -type d -name ".git"); do pushd $(dirname $dir); git pull; popd; done
}

function switch-cluster() {
  gcloud config set project $1
  gcloud config set compute/region $2
  gcloud config set compute/zone $3
  gcloud config set container/cluster $4
  gcloud container clusters get-credentials $4
}

function get-node-by-type() {
  node_regular=$(kubectl get no -l cloud.google.com/gke-preemptible!=true 2>/dev/null)
  node_regular_count=$(($(echo $node_regular | wc -l) -1))
  node_preemptible=$(kubectl get no -l cloud.google.com/gke-preemptible=true 2>/dev/null)
  node_preemptible_count=$(($(echo $node_preemptible | wc -l) -1))

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
}

function get-all() {
  kubectl get hpa,deploy,po,svc,ing,statefulsets,pvc,pv $@
}

function get-pod-by-node() {
  kubectl get po -o wide --sort-by='{.spec.nodeName}' $@
}
