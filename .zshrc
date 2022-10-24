# If not an interactive shell, do nothing
case $- in
*i*) ;;
*) return ;;
esac

# zsh completions with homebrew
if type brew >/dev/null 2>&1
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi

# Disable freezing terminal with ctrl-s (Software Flow Control)
stty -ixon

# Make neovim the default editor
[ -x "$(command -v nvim)" ] && export EDITOR='nvim'

# Force emacs mode in shell
bindkey -e

# History
HISTFILE=~/.zsh_history
HISTSIZE=999999999
SAVEHIST=999999999
setopt BANG_HIST          # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY   # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY      # Share history between all sessions.
setopt HIST_IGNORE_DUPS   # Don't record an entry that was just recorded again.
setopt HIST_REDUCE_BLANKS # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY        # Don't execute immediately upon history expansion.

# Load the shell dotfiles
for file in $HOME/.zsh_prompt $HOME/.zsh_exports $HOME/.zsh_aliases $HOME/.zsh_fns; do
  [ -r "$file" ] && [ -f "$file" ] && . "$file"
done
unset file

# asdf
[ -f "$(brew --prefix asdf)/libexec/asdf.sh" ] && \
  . "$(brew --prefix asdf)/libexec/asdf.sh"
