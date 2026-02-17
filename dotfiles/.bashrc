# Bash Configuration for Linux Bootstrap

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Path configuration
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Editor configuration
export EDITOR='nvim'
export VISUAL='nvim'

# History configuration
HISTCONTROL=ignoreboth:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Make less more friendly for non-text input files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable programmable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Colored prompt
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='\u@\h:\w\$ '
fi

# Aliases
alias vim='nvim'
alias vi='nvim'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Docker aliases (if docker is installed)
if command -v docker &> /dev/null; then
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias dex='docker exec -it'
    alias dlogs='docker logs -f'
fi

# System aliases
alias update='sudo apt update && sudo apt upgrade -y'
alias cleanup='sudo apt autoremove -y && sudo apt autoclean'

# Python/uv aliases
if command -v uv &> /dev/null; then
    alias py='uv run python'
    alias python='uv run python'
    alias pip='uv pip'
fi

# Load uv (Python package manager)
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Load GitHub CLI completions
if command -v gh &> /dev/null; then
    eval "$(gh completion -s bash)"
fi

# Load AWS CLI completions
if command -v aws_completer &> /dev/null; then
    complete -C "$(which aws_completer)" aws
fi

# Node Version Manager (nvm) - if installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Colored ls output
if command -v dircolors &> /dev/null; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# Local customizations (not in version control)
if [ -f ~/.bashrc.local ]; then
    source ~/.bashrc.local
fi

# Welcome message
if [ -n "$PS1" ]; then
    echo "Welcome to $(hostname)!"
    echo "Run 'tailscale status' to check VPN connection"
fi
