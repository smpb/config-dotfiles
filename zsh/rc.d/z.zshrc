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
  eval "$(fzf --zsh 2> /dev/null)"

  # show a preview of the file when searching with ctrl+t
  export FZF_CTRL_T_OPTS="--preview 'less {}'"

  # override the default reverse search
  # necessary for machines with a large history file
  fzf-full-history-widget() {
    BUFFER=$(tac $HISTFILE | perl -0 -ne 'if (!$seen{(/^\s*[0-9]+\**\t(.*)/s, $1)}++) { s/\n/\n\t/g; print; }' | perl -pe 's/^[^;]*;//' | fzf --height 40% --scheme=history)
    CURSOR=${#BUFFER}
    zle reset-prompt
  }

  zle     -N            fzf-full-history-widget
  bindkey -M emacs '^R' fzf-full-history-widget
  bindkey -M vicmd '^R' fzf-full-history-widget
  bindkey -M viins '^R' fzf-full-history-widget
fi

