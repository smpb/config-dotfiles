#
# LLM settings
#

local LLM_DEFAULT_MODEL=gemma3:4b

function question_llm() {
  CMD="llm -s \"Think step by step and answer in as few words as possible using the en-US locale with a brief style of short replies.\" -m $LLM_DEFAULT_MODEL \"$@\""

  if type bat &>/dev/null
  then
    CMD="$CMD | bat --plain --language md --theme TwoDark"
  fi

  eval ${CMD}
}

if type llm &>/dev/null
then
  alias q=question_llm
fi
