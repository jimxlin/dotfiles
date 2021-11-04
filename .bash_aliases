# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

# Shortcuts
alias cddl="cd ~/Downloads"
alias cdpr="cd ~/Projects"
alias g="git"

# Detect which `ls` flavor is in use
if ls --color -d . &>/dev/null; then
  alias ls="ls --color=auto"
elif ls -G -d . &>/dev/null; then
  alias ls='ls -G'
fi

# List all files colorized in long format
alias l="ls -lF"

# List all files colorized in long format, excluding . and ..
alias la="ls -lAF"

# List only directories
alias lsd="ls -lF | grep --color=never '^d'"

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
[[ "$(command -v notify-send)" ]] && alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Use NeoVim
[[ "$(command -v nvim)" ]] && alias vim='nvim'

# todo.txt-cli
[[ "$(command -v todo.sh)" ]] && alias t='todo.sh'

# Retry last command with sudo
alias plz='sudo $(fc -ln -1)'
