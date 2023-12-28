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

setopt promptsubst
setopt nomatch
setopt notify
unsetopt beep

autoload colors; colors;
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
setopt INC_APPEND_HISTORY       # append new history entries to the history file in real-time
setopt SHARE_HISTORY            # enable interactive history sharing between tabs

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
unsetopt menu_complete

# attempt to complete, correct typos up to two mistakes
zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 2 numeric
zstyle ':completion:*:approximate:*' max-errors 2 not-numeric

# correction

setopt correct_all

# make search up and down work,
# so partially type and hit up/down to find relevant stuff

bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

# aliases

alias  mv='nocorrect mv -vi'
alias  cp='nocorrect cp -v'
alias  rm='rm -vI'
alias  ll='ls -Flha'
alias  vi='nocorrect vim'
alias  ..='cd ..'
alias  ...='cd ../..'
alias  git='nocorrect git'
alias  go-go-gadget='sudo' # "Don't worry, Chief, Inspector Gadget is always on duty!"

# use Visual Studio Code for `meld`
if type code &>/dev/null
then
  alias  meld='code --diff'
fi

# only for graphical mode
if [[ $TERM == "xterm" || $TERM == "xterm-color" || $TERM == "xterm-256color" || $TERM == "rxvt" ]]; then
  alias vim=gvim
fi

# git

local GIT_PROMPT_PREFIX="%{$fg[red]%} ["
local GIT_PROMPT_SUFFIX="]%{$reset_color%}"
local GIT_DIRTY_STATUS="*" # ⚡
local GIT_BEHIND_STATUS="<"

# Use `g` instead of `git`:
#   With no arguments: `git status`
#   With arguments: acts like `git`
function g() {
  if [[ $# > 0 ]]; then
    git $@
  else
    git status -s
  fi
}

# Complete `g` like `git`
compdef g=git

# get branch name, if it exists
function git_prompt_info() {
  #local REF=$(git name-rev HEAD 2>/dev/null | awk '{ print $2 }')
  local REF=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  if [[ -n $REF ]]; then
    echo "$GIT_PROMPT_PREFIX$REF$(parse_git_dirty)$(parse_git_behind)$GIT_PROMPT_SUFFIX"
  fi
}

# should we show notification of changes to commit?
parse_git_dirty () {
  if [[ -n $(git status -s -uno 2> /dev/null) ]]; then
    echo " $GIT_DIRTY_STATUS"
  fi
}

# is the current branch behind the remote?
parse_git_behind () {
  if [[ -n $(git status -uno | grep -i behind 2> /dev/null) ]]; then
    echo " $GIT_BEHIND_STATUS"
  fi
}

# prompt

export PS1='%{$fg[red]%}%n@%m%{$fg[blue]%} %B%3~%b$(git_prompt_info)%{$reset_color%} %B$%b '

#local RETURN_CODE="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
#local RETURN_CODE="%(?..%{$fg[red]%}%? %{$reset_color%})"
#export RPS1=$RETURN_CODE

# source transient configurations

local RC_DIR="$ZSH_HOME/rc.d"
if [[ -d $RC_DIR ]]
then
  for RCFILE in "$RC_DIR"/*
  do
    source "$RCFILE"
  done
fi
