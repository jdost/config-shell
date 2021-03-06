local IT="${terminfo[sitm]}${terminfo[bold]}"
local ST="${terminfo[sgr0]}${terminfo[ritm]}"

local FMT_BRANCH="%F{9}(%s:%F{7}%{$IT%}%r%{$ST%}%F{9}) %F{11}%B%b %K{235}%{$IT%}%m%{$ST%}%k"
local FMT_ACTION="(%F{3}%a%f)"
local FMT_PATH="%F{1}%R%F{2}/%S%f"
local VI_STATUS=""
local VI_CURSOR=0

if [ -x $PLUGIN_DIR/hzsh_path ]; then
   local FANCY_PATH_CMD="$PLUGIN_DIR/hzsh_path"
elif which ruby &> /dev/null; then
   local FANCY_PATH_CMD="$PLUGIN_DIR/rzsh_path"
else
   local FANCY_PATH_CMD="echo"
fi

setprompt() {
   local USER="%(#.%F{1}.%F{3})%n%f"
   local HOST="%F{2}%U%M%u%f"
   local PWD="%F{7}$($FANCY_PATH_CMD "$(dirs)")%f"
   local TTY="%F{4}%y%f"
   local EXIT="%(?..%F{0}%K{202}%?%k%f )"
   local JOBS="%(1j.%F{8}(%j%) .)"

   if [[ "${VIRTUAL_ENV}" != "" ]]; then
      local VENV="%F{100}($(basename ${VIRTUAL_ENV})) "
   else
      local VENV=""
   fi

   local PRMPT="${USER}@$HOST:${TTY}: ${PWD}
${VENV}${JOBS}${EXIT}%(1l.. )%F{202}»%f "
   PROMPT="$PRMPT"

   vi-mode
   local RPRMPT=$VI_STATUS
   if [[ "${vcs_info_msg_0_}" != "" ]]; then
      RPROMPT="${vcs_info_msg_0_} $RPRMPT"
   else
      RPROMPT="$RPRMPT"
   fi
}

function vi-mode() {
   local NORMAL="%F{1}N%f"
   local INSERT="%fI"

   VI_STATUS="%F{7}["
   case $KEYMAP in
      vicmd)
         VI_STATUS+=$NORMAL
         (( $CURSOR )) && #
         ;;
      viins|main)
         VI_STATUS+=$INSERT
         (( $CURSOR )) && #
         ;;
   esac

   VI_STATUS+="%F{7}]"
}

function zle-line-init zle-keymap-select {
   setprompt
   zle reset-prompt
}

precmd() {
   vcs_info
   setprompt
   #print -Pn "\e]0;%n@%m: %~\a"
}

preexec() {
   #print -Pn "\e]0;$1\a"
}

# Ensure that the prompt is redrawn when the terminal size changes.
TRAPWINCH() {
   zle && { zle reset-prompt; zle -R }
}

zle -N zle-line-init
zle -N zle-keymap-select

# Show remote ref name and number of commits ahead-of or behind
function +vi-git-st() {
   local ahead behind
   local -a gitstatus

   # for git prior to 1.7
   # ahead=$(git rev-list origin/${hook_com[branch]}..HEAD | wc -l)
   ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
   (( $ahead )) && gitstatus+=( "%F{82}+${ahead}%f" )

   # for git prior to 1.7
   # behind=$(git rev-list HEAD..origin/${hook_com[branch]} | wc -l)
   behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
   (( $behind )) && gitstatus+=( "%F{124}-${behind}%f" )

   staged=$(git diff --name-status --staged | wc -l | tr -d ' ')
   (( $staged )) && gitstatus+=( "%F{252}${staged}%F{220}S%f" )

   unstaged=$(git diff --name-status | sed '/^U/d' | wc -l | tr -d ' ')
   (( $unstaged )) && gitstatus+=( "%F{252}${unstaged}%F{39}U%f" )

   untracked=$(git ls-files --others --exclude-standard "$(git rev-parse --show-toplevel)" | wc -l | tr -d ' ')
   (( $untracked )) && gitstatus+=( "%F{252}${untracked}%F{141}?%f" )

   hook_com[misc]+=${(j:/:)gitstatus}%f
}

# vim: ft=zsh
