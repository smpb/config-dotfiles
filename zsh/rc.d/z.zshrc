#
# command line utilities
#

# 'z' : jump to directories based on frequency of use
if type zoxide &> /dev/null
then
  eval "$(zoxide init zsh)"
fi


# 'fzf' : install useful key bindings and fuzzy completion
if type fzf &> /dev/null
then
  # setup fzf
  if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
    PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
  fi

  # load auto-completion
  source "/opt/homebrew/opt/fzf/shell/completion.zsh"

  # load key bindings
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
fi

