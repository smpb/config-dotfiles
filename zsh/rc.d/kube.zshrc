#
# Kubernetes settings
#

local KUBE_PROMPT_PATH=${KUBE_PROMPT_PATH:-}
local KUBE_PROMPT_COLOR=${KUBE_PROMPT_COLOR:-"%{$fg[magenta]%}"}
local KUBE_PROMPT_PREFIX=${KUBE_PROMPT_PREFIX:-$KUBE_PROMPT_COLOR" 󰔆 "}
local KUBE_PROMPT_SUFFIX=${KUBE_PROMPT_SUFFIX:-"%{$reset_color%}"}
local KUBE_PROMPT_DIVIDER=${KUBE_PROMPT_DIVIDER:-""}

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
    echo "$KUBE_PROMPT_PREFIX$(kube_context)$KUBE_PROMPT_DIVIDER$(kube_namespace)$KUBE_PROMPT_SUFFIX"
  fi
}

if type kubectl &>/dev/null
then
  alias k='kubectl'

  local PROMPT_EXTRA=$PROMPT_EXTRA'$(kube_prompt_info)'

  if kubectl krew >/dev/null 2>&1
  then
    PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  fi
fi

if type helm &>/dev/null
then
  alias h='helm'
fi
