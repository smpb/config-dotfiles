#
# init
#

# don't do anything, if not running interactively
case $- in
    *i*) ;;
      *) return;;
esac

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# filename patterns which match no files to expand to a null string
shopt -s nullglob

# configure prompt command to save and reload history
export PROMPT_COMMAND='history -a; history -c; history -r;'

# enable autocd and set CDPATH
shopt -s autocd
CDPATH=$HOME

# add colors to 'less' and 'man'
export MANPAGER='less -s -M +Gg'    # squeeze blank lines, prompt even more verbosely, jump around to count lines
export PAGER='less -R'              # render color codes
export LESS_TERMCAP_mb=$'\E[00;32m' # enter blinking mode
export LESS_TERMCAP_md=$'\E[00;32m' # enter double-bright mode
export LESS_TERMCAP_me=$'\E[0m'     # turn off all appearance modes (mb, md, so, us)
export LESS_TERMCAP_se=$'\E[0m'     # leave standout mode
export LESS_TERMCAP_ue=$'\E[0m'     # leave underline mode
export LESS_TERMCAP_us=$'\E[00;31m' # enter underline mode

#
# history
#

HISTSIZE=100000
SAVEHIST=10000000
HISTCONTROL=ignoreboth
HISTFILESIZE=$HISTSIZE
HISTTIMEFORMAT="%F %T "
shopt -s histappend
shopt -s cmdhist
shopt -s extglob

#
# aliases
#

alias   cp='cp -v'
alias   ll='ls -Flha --group-directories-first --color=auto'
alias   mv='mv -vi'
alias   rm='rm -vI'
alias   vi='vim'
alias  ...='cd ../..'
alias  git='git'
alias grep='grep --color=auto'
alias dosu='sudo -Es'
alias sudo='sudo '  # use alias expansion (otherwise sudo ignores other aliases)

if type gvim &>/dev/null && [[ $TERM == "xterm" || $TERM == "xterm-color" || $TERM == "xterm-256color" || $TERM == "rxvt" ]]; then
  alias vim=gvim
fi

#
# completion
#

bind 'set show-all-if-ambiguous on' # list available options
bind 'TAB:menu-complete'            # cycle through them with TAB

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ];
  then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ];
  then
    . /etc/bash_completion
  fi
fi

# disable completion after a space
complete -D
complete -cf sudo

complete -F _longopt ll # complete the 'll' alias like 'ls'

# check window size after each command
shopt -s checkwinsize

#
# search
#

# make search up/down work: partially type and hit arrows to find related items
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

#
# prompt
#

# default values
PROMPT_NEWLINE=$'\n'
PROMPT_MACHINE_COLOR="\[\033[0;90m\]"
PROMPT_MACHINE="\u@\h"
PROMPT_SESSION=""
PROMPT_PATH_COLOR="\[\033[0;34m\]"
PROMPT_PATH="\[\033[1m\]\w\[\033[0m\]"
PROMPT_CHEVRON="\[\033[1m\]\$\[\033[0m\] "
PROMPT_EXTRA=" "
PROMPT_RESET_COLOR="\[\033[0m\]"

if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
  PROMPT_SESSION=" \[\033[0;33m[ssh]\[\033[0m\]"
fi

# prompt setup
PS1=$PROMPT_NEWLINE$PROMPT_MACHINE_COLOR$PROMPT_MACHINE$PROMPT_SESSION' '$PROMPT_PATH_COLOR$PROMPT_PATH$PROMPT_RESET_COLOR$PROMPT_EXTRA$PROMPT_NEWLINE$PROMPT_CHEVRON
