#
# LLM settings
#

local LLM_DEFAULT_MODEL=llama3.1:latest

function question_llm() {
  llm -s "Think step by step and answer in as few words as possible using the en-US locale with a brief style of short replies." -m $LLM_DEFAULT_MODEL "$*"
}

if type llm &>/dev/null
then
  alias q=question_llm
fi
