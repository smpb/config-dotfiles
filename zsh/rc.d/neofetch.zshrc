#
# Neofetch bling
#

local NEOFETCH_ACTIVE=${NEOFETCH_ACTIVE:-}
local NEOFETCH_ASCII=${NEOFETCH_ASCII:-}

if [[ -n "$NEOFETCH_ACTIVE" ]] && type neofetch &>/dev/null
then
  neofetch --ascii $NEOFETCH_ASCII
fi
