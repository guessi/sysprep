# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
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

# docker
if [ "${OS_TYPE}" = "Linux" ]; then
  alias dockercontainercleanup='sudo docker ps -q -f status=exited | xargs -r sudo docker rm -f'
  alias dockerimagecleanup='sudo docker images -q -f dangling=true | xargs -r sudo docker rmi -f'
  alias dockerimageupdate='sudo docker images --format "{{.Repository}}:{{.Tag}}" | egrep "^docker.io\/" | xargs -r -n 1 sudo docker pull'
elif [ "${OS_TYPE}" = "Darwin" ]; then
  alias dockercontainercleanup='docker ps -q -f status=exited | xargs docker rm -f'
  alias dockerimagecleanup='docker images -q -f dangling=true | xargs docker rmi -f'
  alias dockerimageupdate='docker images --format "{{.Repository}}:{{.Tag}}" | xargs -n 1 docker pull'
else
  unalias dockercontainercleanup
  unalias dockerimagecleanup
  unalias dockerimageupdate
fi

# custom aliases
if [ -f "~/.bash_aliases" ]; then
  . ~/.bash_aliases
fi
