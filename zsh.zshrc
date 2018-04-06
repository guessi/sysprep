# define GOPATH
export GOPATH=$HOME/go

# If you come from bash you might have to change your $PATH.
export PATH=$GOPATH/bin:$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/local/opt/curl/bin:$PATH

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

PROMPT='%{$fg[blue]%}%n%{$reset_color%}:%{$fg[$user_color]%}$(_fishy_collapsed_wd)%{$reset_color%}$(git_prompt_info)$(git_prompt_status) %# %{$reset_color%}'
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

if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
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
