PROMPT_COMMAND='
PS1="\[\e[0m\]\$(
  if [[ \$? = 0 ]]; then
    echo \"\[\e[32m\]\";
  else
    echo \"\[\e[31m\]\";
  fi
)\u@\h\[\e[0m\]:\[\e[0;34m\]\$(
  echo \"\w\"|sed -r \"s:.+/([^/]+/[^/]+)$:\\1:\";
)\[\e[0m\]\$ ";
echo -ne "\033]0;`hostname -s`:`pwd`\007"
'

