#
# Kitty terminal settings
#

if [[ "$TERM" == "xterm-kitty" ]]
then
  alias ssh='kitten ssh'

  local VIM=vim
  if type nvim &>/dev/null
  then
    VIM=nvim
  fi

  alias gvim="kitty @ launch --type=os-window --cwd=current ${VIM} > /dev/null"
  alias   kl="kitty @ launch --type=os-window --cwd=current $@"
fi
