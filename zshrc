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

  local HOMEBREW_SBIN=/opt/homebrew/sbin
  if [[ -d $HOMEBREW_SBIN ]];
  then
    if [[ -z "$OSXPATH" ]];
    then
      OSXPATH=$HOMEBREW_SBIN
    else
      OSXPATH=$HOMEBREW_SBIN:$OSXPATH
    fi
  fi

  local TAILSCALE_BIN=/Applications/Tailscale.app/Contents/MacOS
  if [[ -d $TAILSCALE_BIN ]];
  then
    alias tailscale="${TAILSCALE_BIN}/Tailscale"
  fi

  # Finish
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

# XDG Base Directory Specification
export XDG_LOCAL_HOME=$HOME/.local
export XDG_BIN_HOME=$XDG_LOCAL_HOME/bin
export XDG_DATA_HOME=$XDG_LOCAL_HOME/share
export XDG_STATE_HOME=$XDG_LOCAL_HOME/state
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache

PATH=$XDG_BIN_HOME:$PATH

#

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

#

# bindkey -v    # activate vi mode
# KEYTIMEOUT=10 # reduce mode switching delay

setopt noclobber    # don't overwrite existing files with output redirection (force it with >| or >!)
setopt appendcreate # the above disables file creation by appending with output redirection, and this re-enables it

setopt PROMPT_SUBST # allow command substitution in prompts (e.g. `$(date)`)
setopt NOMATCH      # don't treat patterns that don't match as errors
setopt NOTIFY       # report the completion status of background jobs immediately
unsetopt BEEP       # disable the terminal bell for errors

#

export WORDCHARS=${WORDCHARS//[-=:\/@\.]}

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

export LESS=' -R -X -F '

if type src-hilite-lesspipe.sh &>/dev/null
then
  LESSPIPE=`which src-hilite-lesspipe.sh`
  export LESSOPEN="| ${LESSPIPE} %s"
fi

#
# history
#

local HISTNAME=zsh_history
local HISTFILE=$ZSH_HOME/$HISTNAME
local HISTORY_IGNORE='([ \t]*|[bf]g|cd|cd ..|clear|dk cmb|dk cmd|dk cmu|dk ps|dk psa|dk rmb|dk rmi|g|g co *|g df|g dfs|g lp|g poop|g pull|g push|g st|g stash|g stu|k|ll|lla|ls|lt|pwd|reset|z)'
local HISTSIZE=500              # how many lines of history to keep in memory
local SAVEHIST=10000000         # how many lines to keep in the history file
setopt EXTENDED_HISTORY         # save each command’s beginning timestamp and the duration
setopt HIST_EXPIRE_DUPS_FIRST   # remove the oldest history events that have duplicates, first
setopt HIST_IGNORE_DUPS         # ignore duplicates when adding commands to history
setopt HIST_IGNORE_SPACE        # ignore commands with leading whitespace in history
setopt HIST_REDUCE_BLANKS       # remove superfluous blanks from each command line being added to the history
setopt HIST_VERIFY              # verify commands before executing them from history
setopt INC_APPEND_HISTORY_TIME  # append new entries to the history file right after the command exits, with the elapsed time

# backup history file with rotation
if [[ $(find "$HISTFILE.tgz" -mtime +0 2>/dev/null) ]]; then
  for i in {4..1}
  do
    if [[ -f $HISTFILE.$i.tgz ]]; then
      mv $HISTFILE.$i.tgz $HISTFILE.$((i+1)).tgz
    fi
  done

  if [[ -f $HISTFILE.tgz ]]; then
    mv $HISTFILE.tgz $HISTFILE.1.tgz
  fi

  tar czf $HISTFILE.tgz -C $ZSH_HOME $HISTNAME
fi

#
# completion
#

# initialization
#   -U  suppresses alias expansion
#   -z  forces zsh-style loading in which the function definition file will be sourced only once
autoload -Uz compinit

if [[ $(find "$ZSH_HOME/zcompdump" -mtime +0 2>/dev/null) ]]; then
  compinit -d $ZSH_HOME/zcompdump
  touch $ZSH_HOME/zcompdump
else
  compinit -C -d $ZSH_HOME/zcompdump
fi

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
CORRECT_IGNORE_FILE='.*'

#
# search
#

# make search up/down work: partially type and hit arrows to find related items
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search

#
# aliases
#

if [[ "$OSTYPE" == "darwin"* ]];
then
  alias   cp='cp -vc'  # macOS 'cp` with APFS can create copy on write clones of files
else
  alias   cp='cp -v'
fi

alias   mv='mv -vi'
alias   rm='rm -vI'
alias  git='nocorrect git'
alias grep='grep --color=auto'
alias sudo='sudo -E '  # use alias expansion (otherwise sudo ignores other aliases); preserve env

# use a better 'ls' on macOS (installed via 'coreutils' in Homebrew)
if type gls &>/dev/null
then
  alias  ls='gls --group-directories-first --color=auto'
  alias  ll='gls -lhF --group-directories-first --color=auto'
  alias lla='gls -lhAF --group-directories-first --color=auto'
  alias  lt='gls -d "$PWD"/* "$PWD"/**/* --color=auto'
else
  alias  ll='ls -lhF'
  alias lla='ls -lhAF'
  alias  lt='ls -d "$PWD"/* "$PWD"/**/*'
fi

if type tree &>/dev/null
then
  alias lt='tree -C'
fi

# use 'eza' for detailed listings, if available
if type eza &>/dev/null
then
  alias  ll='eza -olhgF  --no-permissions --group-directories-first --color-scale=all --time-style=long-iso --git'
  alias lla='eza -olhgAF --no-permissions --group-directories-first --color-scale=all --time-style=long-iso --git'
  alias  lt='eza -olhgTF --no-permissions --group-directories-first --color-scale=all --time-style=long-iso --git'
fi

# use 'bat' as 'less', if available
if type bat &>/dev/null
then
  alias less='bat --theme TwoDark'
fi

# prefer Neovim, then Vim; always use the chosen one as `meld`
if type nvim &>/dev/null
then
  export EDITOR='nvim'
  export VISUAL='nvim'
  export MANPAGER='nvim +Man!'

  alias   vi=nvim
  alias  vim=nvim
  alias gvim=nvim
  alias meld='nvim -d'
elif type vim &>/dev/null
then
  export EDITOR='vim'
  export VISUAL='vim'

  alias   vi=vim
  alias gvim=vim
  alias meld='vim -d'
else
  alias meld='vi -d'
fi

# edit Zsh history, leave no trace
alias viz=' vi + ${ZSH_HOME}/zsh_history'

# jump into Tmux from SSH
#   'sh' uses '-l' to load more $PATH because on macOS 'tmux' is in a non-standard place.
function ssht() {
  ssh -A -t "$@" 'sh -l -c "tmux -u new -A -s ssht || tmux -u attach -t ssht || tmux -u new-session -s ssht" || $SHELL -l'
}

compdef ssht=ssh

#
# prompt
#

# default values
local PROMPT_NEWLINE=$'\n'
local PROMPT_MACHINE_COLOR="%{$fg[magenta]%}"
local PROMPT_MACHINE="%n@%m"
local PROMPT_SESSION=""
local PROMPT_SESSION_COLOR="%{$fg[yellow]%}"
local PROMPT_PATH_COLOR="%{$fg[blue]%}"
local PROMPT_PATH="%B%10~%b%"
local PROMPT_CHEVRON="%B$%b "
local PROMPT_EXTRA=""
local PROMPT_RESET_COLOR="{$reset_color%}"

if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]];
then
  if [[ -n "$TMUX" ]];
  then
    PROMPT_SESSION='(ssh|tmux)'
  else
    PROMPT_SESSION='(ssh)'
  fi
elif [[ -n "$TMUX" ]];
then
  PROMPT_SESSION='(tmux)'
fi


function set-prompt {
  PROMPT=$PROMPT_NEWLINE$PROMPT_MACHINE_COLOR$PROMPT_MACHINE$PROMPT_SESSION' '$PROMPT_PATH_COLOR$PROMPT_PATH$PROMPT_RESET_COLOR$PROMPT_EXTRA$PROMPT_NEWLINE$PROMPT_CHEVRON
}

# local RETURN_CODE="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"
# local RETURN_CODE="%(?..%{$fg[red]%}%? %{$reset_color%})"
# export RPS1=$RETURN_CODE

#
# source non-core configurations
#

local RC_DIR="$ZSH_HOME/rc.d"
if [[ -d $RC_DIR ]]
then
  for RCFILE in "$RC_DIR"/*.zshrc
  do
    source "$RCFILE"
  done
fi

#
# final configurations not to be overriden by `rc.d` add-ons
#
export ZSH_INITIALIZED=1

# set the prompt
set-prompt

