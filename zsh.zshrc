# GOPATH
export GOPATH=$HOME/go
export GOPROXY=direct

# PATH
export PATH="$HOME/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
export PATH="/opt/homebrew/opt/node@24/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"
export PATH="$HOME/.krew/bin:$PATH"
export PATH="$HOME/.toolbox/bin:$PATH"
export PATH="$(gem environment gemdir)/bin:$PATH"

# locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# history
export HIST_STAMPS="yyyy-mm-dd"
export HISTFILE=~/.zsh_history
export HISTSIZE=25000
export SAVEHIST=10000

# cargo
export CARGO_NET_GIT_FETCH_WITH_CLI=true

# set default AWS profile
export AWS_PROFILE=admin

# to fix errot prompt of 'command not found: compdef'
autoload -Uz compinit
compinit

# disable omz update
# - https://github.com/ohmyzsh/ohmyzsh?tab=readme-ov-file#getting-updates
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
  ohmyzsh/ohmyzsh path:plugins/screen
  ohmyzsh/ohmyzsh path:plugins/z

  ohmyzsh/ohmyzsh path:themes/fishy.zsh-theme
BUNDLES

# User configuration
unsetopt beep

# command prompt
PROMPT='%{$fg[blue]%}%n%{$reset_color%}:%{$fg[green]%}$(_fishy_collapsed_wd)%{$reset_color%}$(git_prompt_info)$(git_prompt_status) %# %{$reset_color%}'
RPROMPT=''

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# customized aliases
if [ -f ~/.zshrc.aliases ]; then
  source ~/.zshrc.aliases
fi
