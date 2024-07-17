#
# Git settings
#

local GIT_PROMPT_COLOR="%{$fg[red]%}"
local GIT_PROMPT_PREFIX=$GIT_PROMPT_COLOR" "
local GIT_PROMPT_SUFFIX="%{$reset_color%}"
local GIT_DIRTY_STATUS="%{$fg[yellow]%}[]%{$reset_color%}"
local GIT_STAGED_STATUS="%{$fg[green]%}[]%{$reset_color%}"
local GIT_BEHIND_STATUS="%{$fg[cyan]%}[]%{$reset_color%}"

# Use `g` instead of `git`:
#   With no arguments: `git status`
#   With arguments: acts like `git`
function g() {
  if [[ $# > 0 ]]; then
    git $@
  else
    git status -s .
  fi
}

# Complete `g` like `git`
compdef g=git

# get branch name, if it exists
function git_prompt_info() {
  local REF=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
  if [[ -n $REF ]]; then
    echo "$GIT_PROMPT_PREFIX$REF$(parse_git_dirty)$(parse_git_staged)$(parse_git_behind)$GIT_PROMPT_SUFFIX"
  fi
}

# are there staged files waiting to be commited?
function parse_git_staged() {
  if [[ -n $(git diff --name-only --cached 2> /dev/null) ]]; then
    echo " $GIT_STAGED_STATUS"
  fi
}

# are there modified files?
function parse_git_dirty() {
  if [[ -n $(git ls-files -m 2> /dev/null) ]]; then
    echo " $GIT_DIRTY_STATUS"
  fi
}

# is the current branch behind the remote?
function parse_git_behind() {
  if [[ -n $(git status -uno | grep -i behind 2> /dev/null) ]]; then
    echo " $GIT_BEHIND_STATUS"
  fi
}

local PROMPT_EXTRA=$PROMPT_EXTRA'$(git_prompt_info)'
