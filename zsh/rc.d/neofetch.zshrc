#
# Neofetch bling
#

local NEOFETCH_ACTIVE=${NEOFETCH_ACTIVE:-}
local NEOFETCH_OPTS=${NEOFETCH_OPTS:-"--ascii"}

if [[ -n "$NEOFETCH_ACTIVE" ]] && [[ -z "$ZSH_INITIALIZED" ]] && type neofetch &>/dev/null
then
  eval "neofetch $NEOFETCH_OPTS"
fi
