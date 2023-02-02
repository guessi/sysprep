# GOPATH
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export GOPROXY=direct

# PATH
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/curl/bin:$PATH"
export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
export PATH="$HOME/.krew/bin:$PATH"
export PATH="$HOME/.toolbox/bin:$PATH"

# locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# history
export HIST_STAMPS="yyyy-mm-dd"
export HISTFILE=~/.zsh_history
export HISTSIZE=25000
export SAVEHIST=10000

# set default AWS profile
export AWS_PROFILE=admin

# setup nvm
export NVM_DIR="$HOME/.nvm"

if [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
  source "/usr/local/opt/nvm/nvm.sh"
fi

if [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ]; then
  source "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# disable omz update
zstyle ':omz:update' mode disabled

# antidote

source ${ZDOTDIR:-~}/.antidote/antidote.zsh
source <(antidote init)

antidote bundle <<BUNDLES
  zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-completions

  ohmyzsh/ohmyzsh path:lib
  ohmyzsh/ohmyzsh path:plugins/colored-man-pages
  ohmyzsh/ohmyzsh path:plugins/command-not-found
  ohmyzsh/ohmyzsh path:plugins/pyenv
  ohmyzsh/ohmyzsh path:plugins/screen
  ohmyzsh/ohmyzsh path:plugins/z

  ohmyzsh/ohmyzsh path:themes/fishy.zsh-theme
BUNDLES

# User configuration
unsetopt beep

# command prompt
PROMPT='%{$fg[blue]%}%n%{$reset_color%}:%{$fg[green]%}$(_fishy_collapsed_wd)%{$reset_color%}$(git_prompt_info)$(git_prompt_status) %# %{$reset_color%}'
RPROMPT=''

# customized aliases
if [ -f ~/.zshrc.aliases ]; then
  source ~/.zshrc.aliases
fi
