# Recommended programs
#   - neovim
#   - tmux plugin manager
#   - junegunn/fzf
#   - burntsushi/ripgrep
#   - ajeetdsouza/zoxide
#   - notify-send

# If not an interactive shell, do nothing
case $- in
*i*) ;;
*) return ;;
esac

# Disable freezing terminal with ctrl-s (Software Flow Control)
stty -ixon

# Load the shell dotfiles
# * ~/.path can be used to extend `$PATH`.
for file in ~/.{path,bash_prompt,bash_exports,bash_aliases,bash_functions}; do
  [ -r "$file" ] && [ -f "$file" ] && . "$file"
done
unset file

#==============================================================================
# Built in shell options
#==============================================================================

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Enable some Bash 4 features when possible:
for option in autocd globstar; do
  shopt -s "$option" 2>/dev/null
done

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Prevent closing terminal with C-d
set -o ignoreeof

#==============================================================================
# Utilities
#==============================================================================

# Offers quick access to files and directories
[ -x "$(command -v zoxide)" ] && eval "$(zoxide init bash)"

# Use bash-completion, if available
if [ -f "/etc/bash_completion" ]; then
  . "/etc/bash_completion"
elif [ -f "$(brew --prefix)/etc/bash_completion" ]; then
  . "$(brew --prefix)/etc/bash_completion"
fi

# asdf
[ -f "$HOME/.asdf/asdf.sh" ] && \
  . "$HOME/.asdf/asdf.sh"
[ -f "$HOME/.asdf/completions/asdf.bash" ] && \
  . "$HOME/.asdf/completions/asdf.bash"
