# init

local ZSH_HOME=~/.zsh

if [[ "$OSTYPE" == "darwin"* ]];
then
  # VS Code
  local VSCODE_BIN=/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin
  if [[ -d $VSCODE_BIN ]];
  then
    PATH=$VSCODE_BIN:$PATH
  fi

  # MacVim
  local MACVIM_BIN=/Applications/MacVim.app/Contents/bin
  if [[ -d $MACVIM_BIN ]];
  then
    PATH=$MACVIM_BIN:$PATH
  fi

  # Homebrew
  local HOMEBREW_BIN=/opt/homebrew/bin
  if [[ -d $HOMEBREW_BIN ]];
  then
    PATH=$HOMEBREW_BIN:$PATH
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

autoload colors && colors;
export CLICOLOR=1
export LSCOLORS="Gxfxcxdxbxegedabagacad"

# history

local HISTFILE=$ZSH_HOME/zsh_history
local HISTSIZE=100000
local SAVEHIST=100000
setopt EXTENDED_HISTORY         # save each command’s beginning timestamp and the duration
setopt HIST_EXPIRE_DUPS_FIRST   # remove the oldest history events that have duplicates, first
setopt HIST_IGNORE_DUPS         # ignore duplicates when adding commands to history
setopt HIST_IGNORE_SPACE        # ignore commands with leading whitespace in history
setopt HIST_REDUCE_BLANKS       # remove superfluous blanks from each command line being added to the history
setopt HIST_VERIFY              # verify commands before executing them from history
setopt INC_APPEND_HISTORY_TIME  # append new entries to the history file right after the command exits, with the elapsed time

# completion

autoload -U compinit # initialization

# macOS `brew` completions, if available
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

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

# correction

setopt CORRECT_ALL

# make search up and down work,
# so partially type and hit up/down to find relevant stuff

bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# aliases

alias   cp='cp -v'
alias   ll='ls -Flha'
alias   mv='mv -vi'
alias   rm='rm -vI'
alias   vi='nocorrect vim'
alias  ...='cd ../..'
alias  git='nocorrect git'
alias sudo='sudo '          # use alias expansion (otherwise sudo ignores other aliases)

# use Visual Studio Code for `meld`
if type code &>/dev/null
then
  alias -g meld='code --diff'
fi

# only for graphical mode
if [[ $TERM == "xterm" || $TERM == "xterm-color" || $TERM == "xterm-256color" || $TERM == "rxvt" ]]; then
  alias -g vim=gvim
fi

# prompt

# default values
local PROMPT_NEWLINE=$'\n'
local PROMPT_MACHINE_COLOR="%{$fg[red]%}"
local PROMPT_MACHINE="%n@%m"
local PROMPT_PATH_COLOR="%{$fg[blue]%}"
local PROMPT_PATH="%B%3~%b%"
local PROMPT_CHEVRON="%B$%b "
local PROMPT_EXTRA=" "
local PROMPT_RESET_COLOR="{$reset_color%}"

#local RETURN_CODE="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
#local RETURN_CODE="%(?..%{$fg[red]%}%? %{$reset_color%})"
#export RPS1=$RETURN_CODE

# source thematic configurations

local RC_DIR="$ZSH_HOME/rc.d"
if [[ -d $RC_DIR ]]
then
  for RCFILE in "$RC_DIR"/*
  do
    source "$RCFILE"
  done
fi

# final configurations not to be overriden by `rc.d` add-ons

# prompt setup
PROMPT=$PROMPT_NEWLINE$PROMPT_MACHINE_COLOR$PROMPT_MACHINE' '$PROMPT_PATH_COLOR$PROMPT_PATH$PROMPT_RESET_COLOR$PROMPT_EXTRA$PROMPT_NEWLINE$PROMPT_CHEVRON

