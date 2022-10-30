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

# history
HISTTIMEFORMAT='%F %T '

# custom aliases
if [ -f "~/.bash_aliases" ]; then
  . ~/.bash_aliases
fi

# customized aliases
if [ -f ~/.bashrc.aliases ]; then
  source ~/.bashrc.aliases
fi
