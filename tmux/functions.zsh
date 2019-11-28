export DEFAULT_TMUX=default
export TMUX_LOCATION=/tmp/tmux/

if [[ ! -d $TMUX_LOCATION ]]; then
   mkdir $TMUX_LOCATION
fi

# alias tmux to add some better defaults {{{
tmux () {
   local TMUX_BIN=$(bash -c "which tmux")
   if [[ $# == 0 ]]; then
      tmux s $DEFAULT_TMUX
      return
   fi

   case $1 in
      start|new|s)
         local name=${2:-$DEFAULT_TMUX}
         settitle $name
          $TMUX_BIN -S $TMUX_LOCATION$name new-session -s $name -d
         chmod 777 $TMUX_LOCATION$name
          $TMUX_BIN -S $TMUX_LOCATION$name attach -t $name
         ;;
      attach|a)
         local name=${2:-$DEFAULT_TMUX}
         settitle $name
          $TMUX_BIN -S $TMUX_LOCATION$name attach -t $name
         ;;
      detach|d)
         if [[ -z "$TMUX" ]]; then
            exit 0;
         fi
          $TMUX_BIN detach
         ;;
      ls)
         /usr/bin/ls $TMUX_LOCATION
         ;;
      *)
          $TMUX_BIN $*
         ;;
   esac
} # }}}

# quickly switch to tmux layouts {{{
layout () {
   local layout=$XDG_CONFIG_HOME/tmux/${1:-default}
   local TMUX_BIN=$(bash -c "which tmux")

   if [[ -z $TMUX ]]; then
      return # open default tmux with this layout?
   fi
    $TMUX_BIN source $layout
} # }}}

# tmux window naming {{{
settitle () {
   ALL=$*
   TITLE=${ALL:=$(echo $TTY | cut -d/ -f 3-)}

   if [[ -z "$TMUX" ]]; then
      echo -ne "\033]0;$TITLE\007"
   else
      printf "\033k$TITLE\033\\"
   fi
}
# }}}

# ssh+tmux naming {{{
ssh () {
   if [[ $# == 0 || -z $TMUX ]]; then
       command ssh -A $@
      return
   fi
   # Grab hostname
   local remote=${${(P)#}%.*}
   local old_name="$(tmux display-message -p '#W')"
   local renamed=0
   # rename
   if [[ $remote != -* ]]; then
      renamed=1
       settitle "$remote"
   fi
    command ssh $@
   if [[ $renamed == 1 ]]; then
      renamed=0
       settitle "$old_name"
   fi
} # }}}
