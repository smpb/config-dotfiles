#
# Kubernetes settings
#

local KUBE_PROMPT_PATH=""
local KUBE_PROMPT_COLOR="%{$fg[magenta]%}"
local KUBE_PROMPT_PREFIX=$KUBE_PROMPT_COLOR" 󰔆 "
local KUBE_PROMPT_SUFFIX="%{$reset_color%}"

function is_kubedir() {
  # if we defined a path to check, use that
  if [[ -n "$KUBE_PROMPT_PATH" ]]; then
    local CWD=$(pwd)
    local PARENT_PATH=$(realpath "$KUBE_PROMPT_PATH")

    if [[ "$CWD" = "$PARENT_PATH"* ]]; then
      return 0;
    fi
  fi

  return 1
}

function kube_context {
  echo $(kubectl config current-context)
}

function kube_namespace {
  echo $(kubectl config view --minify --output 'jsonpath={..namespace}')
}

function kube_prompt_info() {
  if RES=$(is_kubedir); then
    echo "$KUBE_PROMPT_PREFIX$(kube_context)󰇙$(kube_namespace)$KUBE_PROMPT_SUFFIX"
  fi
}

if type kubectl &>/dev/null
then
  alias k='kubectl'

  local PROMPT_EXTRA=$PROMPT_EXTRA'$(kube_prompt_info)'
fi

if type helm &>/dev/null
then
  alias h='helm'
fi
