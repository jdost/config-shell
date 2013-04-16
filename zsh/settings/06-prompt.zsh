local IT="${terminfo[sitm]}${terminfo[bold]}"
local ST="${terminfo[sgr0]}${terminfo[ritm]}"

local FMT_BRANCH="%F{9}(%s:%F{7}%{$IT%}%r%{$ST%}%F{9}) %F{11}%B%b %K{235}%{$IT%}%u%c%{$ST%}%k"
local FMT_ACTION="(%F{3}%a%f)"
local FMT_PATH="%F{1}%R%F{2}/%S%f"

if [ -x $PLUGIN_DIR/hzsh_path ]; then
   local FANCY_PATH_CMD="$PLUGIN_DIR/hzsh_path"
else; then
   local FANCY_PATH_CMD="$PLUGIN_DIR/rzsh_path"
fi

setprompt() {
   local USER="%(#.%F{1}.%F{3})%n%f"
   local HOST="%F{2}%U%M%u%f"
   local PWD="%F{7}$($FANCY_PATH_CMD "$(dirs)")%f"
   local TTY="%F{4}%y%f"
   local EXIT="%(?..%F{0}%K{202}%?%k%f)"

   if [[ "${VIRTUAL_ENV}" != "" ]]; then
      local VENV="%F{100}($(basename ${VIRTUAL_ENV})) "
   else
      local VENV=""
   fi

   local PRMPT="${USER}@$HOST:${TTY}: ${PWD} ${EXIT}
${VENV}%F{202}»%f "

   PROMPT="$PRMPT"
   if [[ "${vcs_info_msg_0_}" != "" ]]; then
      RPROMPT="${vcs_info_msg_0_}"
   else
      RPROMPT=""
   fi
}

precmd() {
   vcs_info
   setprompt
   print -Pn "\e]0;%n@%m: %~\a"
}

preexec() {
   #print -Pn "\e]0;$1\a"
}

# vim: ft=zsh
