# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# disable auto update (manual update: upgrade_oh_my_zsh)
DISABLE_UPDATE_PROMPT=true
DISABLE_AUTO_UPDATE=true

# history
export HIST_STAMPS="yyyy-mm-dd"
export HISTIGNORE="&:ls:bg:fg:exit:clear:cd"
export HISTSIZE=25000
export HISTFILE=~/.zsh_history
export SAVEHIST=10000

# antigen
source ~/.antigen/antigen.zsh

antigen use oh-my-zsh
antigen theme fishy

antigen bundles << BUNDLES
  colored-man-pages
  command-not-found
  docker
  git
  git-extras
  pip
  screen
  vagrant
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
alias mv='mv -i'
alias rm='rm -i'

alias df='df -kTh'
alias diff='colordiff'
alias du='du -kh'
alias h='history'
alias j='job -l'
alias ls='ls -FG'
alias ll='ls -l'
alias vi='vim'

alias g='git'

alias dockercontainercleanup='docker ps -q -f status=exited | xargs docker rm -f'
alias dockerimagecleanup='docker images -q -f dangling=true | xargs docker rmi -f'
alias dockerimageupdate='docker images --format "{{.Repository}}:{{.Tag}}" | xargs -n 1 docker pull'
