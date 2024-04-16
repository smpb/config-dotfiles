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

  # load auto-completion and key bindings
  eval "$(fzf --zsh)"

  # show a preview of the file when searching with ctrl+t
  export FZF_CTRL_T_OPTS="--preview 'less {}'"
fi

