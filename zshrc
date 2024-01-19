#
# init
#

local ZSH_HOME=~/.zsh

if [[ "$OSTYPE" == "darwin"* ]];
then
  local OSXPATH=""

  # VS Code
  local VSCODE_BIN=/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin
  if [[ -d $VSCODE_BIN ]];
  then
    if [[ -z "$OSXPATH" ]];
    then
      OSXPATH=$VSCODE_BIN
    else
      OSXPATH=$VSCODE_BIN:$OSXPATH
    fi
  fi

  # MacVim
  local MACVIM_BIN=/Applications/MacVim.app/Contents/bin
  if [[ -d $MACVIM_BIN ]];
  then
    if [[ -z "$OSXPATH" ]];
    then
      OSXPATH=$MACVIM_BIN
    else
      OSXPATH=$MACVIM_BIN:$OSXPATH
    fi
  fi

  # Homebrew
  local HOMEBREW_BIN=/opt/homebrew/bin
  if [[ -d $HOMEBREW_BIN ]];
  then
    if [[ -z "$OSXPATH" ]];
    then
      OSXPATH=$HOMEBREW_BIN
    else
      OSXPATH=$HOMEBREW_BIN:$OSXPATH
    fi

    # include any available Homebrew completions
    FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
  fi

  if [[ ! -z "$OSXPATH" ]];
  then
    PATH=$OSXPATH:$PATH
  fi
elif [[ "$OSTYPE" == "linux-gnu"* ]];
then
  # NOP
fi

# Golang
local GO_DIR=$HOME/Developer/go
if [[ -d $GO_DIR ]];
then
  export GOPATH=$GO_DIR
  PATH=$GO_DIR/bin:$PATH
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

#

setopt PROMPT_SUBST
setopt NOMATCH
setopt NOTIFY
unsetopt BEEP

setopt AUTO_CD
CDPATH=$HOME

# Color codes:
#   30 – black
#   31 – red
#   32 – green
#   33 – orange
#   34 – blue
#   35 – magenta
#   36 – cyan
#   37 – white
#   90 — dark grey
#   91 — light red
#   92 — light green
#   93 — yellow
#   94 — light blue
#   95 — light purple
#   96 — turquoise
#
# Background codes:
#   40 — black
#   41 — red
#   42 — green
#   43 — orange
#   44 — blue
#   45 — purple
#   46 — cyan
#   47 — grey
#  100 — dark grey
#  101 — light red
#  102 — light green
#  103 — yellow
#  104 — light blue
#  105 — light purple
#  106 — turquoise
#
# Other escape codes:
#    0 – reset/normal
#    1 – bold
#    3 – italic/reversed
#    4 – underlined
#    5 – blink
#    7 — reverse (background colour on foreground colour)

autoload colors && colors;
export CLICOLOR=1
export LSCOLORS="Exfxcxdxbxegedabagacad" # https://gist.github.com/smpb/df1e788f0993fafc7f1e5fe3694612f1

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

local HISTFILE=$ZSH_HOME/zsh_history
local HISTSIZE=100000           # how many lines of history to keep in memory
local SAVEHIST=10000000         # how many lines to keep in the history file
setopt EXTENDED_HISTORY         # save each command’s beginning timestamp and the duration
setopt HIST_EXPIRE_DUPS_FIRST   # remove the oldest history events that have duplicates, first
setopt HIST_IGNORE_DUPS         # ignore duplicates when adding commands to history
setopt HIST_IGNORE_SPACE        # ignore commands with leading whitespace in history
setopt HIST_REDUCE_BLANKS       # remove superfluous blanks from each command line being added to the history
setopt HIST_VERIFY              # verify commands before executing them from history
setopt INC_APPEND_HISTORY_TIME  # append new entries to the history file right after the command exits, with the elapsed time

#
# completion
#

# initialization
#   -U  suppresses alias expansion
#   -z  forces zsh-style loading in which the function definition file will be sourced only once
autoload -Uz compinit

compinit -d $ZSH_HOME/zcompdump

# display colors in selection menus
zmodload -i zsh/complist
zstyle ':completion:*' list-colors $LSCOLORS

# use cache for quicker initialization
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $ZSH_HOME/cache

# display selection menu if there are more than two matches
zstyle ':completion:*' menu yes=2 select
unsetopt MENU_COMPLETE

# attempt to complete, correct typos up to two mistakes
zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 2 numeric
zstyle ':completion:*:approximate:*' max-errors 2 not-numeric

# group completions and display a heading for each
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format %d

#
# correction
#

setopt CORRECT_ALL

#
# search
#

# make search up/down work: partially type and hit arrows to find related items
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

#
# aliases
#

alias   cp='cp -v'
alias   mv='mv -vi'
alias   rm='rm -vI'
alias   vi='nocorrect vim'
alias  ...='cd ../..'
alias  git='nocorrect git'
alias grep='grep --color=auto'
alias sudo='sudo '  # use alias expansion (otherwise sudo ignores other aliases)

# use a better 'ls' on macOS (installed via 'coreutils' in Homebrew)
if type gls &>/dev/null
then
  alias ls='gls --group-directories-first --color=auto'
  alias ll='gls -Flha --group-directories-first --color=auto'
else
  alias ll='ls -Flha'
fi

# use Visual Studio Code for `meld`
if type code &>/dev/null
then
  alias -g meld='code --diff'
fi

# only for graphical mode
if (type gvim &>/dev/null) && [[ $TERM == "xterm" || $TERM == "xterm-color" || $TERM == "xterm-256color" || $TERM == "rxvt" ]]; then
  alias -g vim=gvim
fi

# jump into Tmux from SSH
#   'sh' uses '-l' to load more $PATH because on macOS 'tmux' is in a non-standard place.
function ssht() {
  ssh -A -t "$@" 'sh -l -c "tmux -u new -A -s $USER-ssh || tmux -u attach -t $USER-ssh || tmux -u new-session -s $USER-ssh" || $SHELL -l'
}

compdef ssht=ssh

#
# prompt
#

# default values
local PROMPT_NEWLINE=$'\n'
local PROMPT_MACHINE_COLOR="%{$fg[red]%}"
local PROMPT_MACHINE="%n@%m"
local PROMPT_SESSION=""
local PROMPT_SESSION_COLOR="%{$fg[yellow]%}"
local PROMPT_PATH_COLOR="%{$fg[blue]%}"
local PROMPT_PATH="%B%3~%b%"
local PROMPT_CHEVRON="%B$%b "
local PROMPT_EXTRA=" "
local PROMPT_RESET_COLOR="{$reset_color%}"

if [[ -n "$TMUX" ]];
then
  PROMPT_SESSION=' '$PROMPT_SESSION_COLOR'[tmux]'
elif [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]];
then
  PROMPT_SESSION=' '$PROMPT_SESSION_COLOR'[ssh]'
fi

#local RETURN_CODE="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
#local RETURN_CODE="%(?..%{$fg[red]%}%? %{$reset_color%})"
#export RPS1=$RETURN_CODE

#
# source non-core configurations
#

local RC_DIR="$ZSH_HOME/rc.d"
if [[ -d $RC_DIR ]]
then
  for RCFILE in "$RC_DIR"/*
  do
    source "$RCFILE"
  done
fi

#
# final configurations not to be overriden by `rc.d` add-ons
#

# prompt setup
PROMPT=$PROMPT_NEWLINE$PROMPT_MACHINE_COLOR$PROMPT_MACHINE$PROMPT_SESSION' '$PROMPT_PATH_COLOR$PROMPT_PATH$PROMPT_RESET_COLOR$PROMPT_EXTRA$PROMPT_NEWLINE$PROMPT_CHEVRON

