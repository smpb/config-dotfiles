#
# Git settings
#

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
function parse_git_dirty() {
  if [[ -n $(git status -s -uno 2> /dev/null) ]]; then
    echo " $GIT_DIRTY_STATUS"
  fi
}

# is the current branch behind the remote?
function parse_git_behind() {
  if [[ -n $(git status -uno | grep -i behind 2> /dev/null) ]]; then
    echo " $GIT_BEHIND_STATUS"
  fi
}

export PS1='%{$fg[red]%}%n@%m%{$fg[blue]%} %B%3~%b$(git_prompt_info)%{$reset_color%} %B$%b '

