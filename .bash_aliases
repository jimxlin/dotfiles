# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

# Shortcuts
alias cddl="cd ~/Downloads"
alias cdpr="cd ~/Projects"

# git
alias g="git"
if type _git &> /dev/null; then
  complete -o default -o nospace -F _git g;
fi;

# Enable aliases to be sudo'ed
alias sudo='sudo '

# Detect which `ls` flavor is in use
if ls --color -d . &>/dev/null; then
  alias ls="ls --color=auto"
elif ls -G -d . &>/dev/null; then
  alias ls="ls -G"
fi

# List all files colorized in long format
alias l="ls -lF"

# List all files colorized in long format, excluding . and ..
alias la="ls -lAF"

# List only directories
alias lsd="ls -lF | grep --color=never '^d'"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
[ -x "$(command -v notify-send)" ] && alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Use NeoVim
[ -x "$(command -v nvim)" ] && alias vim='nvim'

# Retry last command with sudo
alias plz='sudo $(fc -ln -1)'
