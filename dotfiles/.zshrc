# ZSH Configuration for Linux Bootstrap

# Path configuration
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Editor configuration
export EDITOR='nvim'
export VISUAL='nvim'

# History configuration
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Completion
autoload -Uz compinit
compinit

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

# Load Tailscale completions if available
if command -v tailscale &> /dev/null; then
    # Tailscale doesn't provide shell completions by default, but adding for future
    # completions can be added here if needed
fi

# Load GitHub CLI completions
if command -v gh &> /dev/null; then
    eval "$(gh completion -s zsh)"
fi

# Load AWS CLI completions
if command -v aws_completer &> /dev/null; then
    complete -C "$(which aws_completer)" aws
fi

# Node Version Manager (nvm) - if installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Custom prompt (simple and clean)
# Shows: username@hostname:path$
# Customize this to your preference
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# Show git branch in prompt if in a git repo
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt PROMPT_SUBST
zstyle ':vcs_info:git:*' formats ' (%b)'
zstyle ':vcs_info:*' enable git
RPROMPT='%F{yellow}${vcs_info_msg_0_}%f'

# Colored ls output
if command -v dircolors &> /dev/null; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# Local customizations (not in version control)
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

# Welcome message
if [ -n "$PS1" ]; then
    echo "Welcome to $(hostname)!"
    echo "Run 'tailscale status' to check VPN connection"
fi
