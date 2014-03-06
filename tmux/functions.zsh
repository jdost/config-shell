export DEFAULT_TMUX=default
export TMUX_LOCATION=/tmp/tmux/
# alias tmux to add some better defaults {{{
tmux () {
   if [[ $# == 0 ]]; then
      tmux $DEFAULT_TMUX
      return
   fi

   case $1 in
      [start|new|s])
         local name=${2:-$DEFAULT_TMUX}
          tmux -S $TMUX_LOCATION$name new-session -s $name -d
         chmod 777 $TMUX_LOCATION$name
          tmux -S $TMUX_LOCATION$name attach -t $name
         ;;
      [attach|a])
         local name=${2:-$DEFAULT_TMUX}
          tmux -S $TMUX_LOCATION$name attach -t $name
         ;;
      [detach|d])
         if [[ -z "$TMUX" ]]; then
            exit 0;
         fi
          tmux detach
         ;;
      *)
          tmux $*
         ;;
   esac
} # }}}

# quickly switch to tmux layouts {{{
layout () {
   local layout=$XDG_CONFIG_HOME/tmux/${1:-default}
   if [[ -z $TMUX ]]; then
      return # open default tmux with this layout?
   fi
    tmux source $layout
} # }}}

# tmux window naming {{{
settitle () { printf "\033k$*\033\\" }
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
      tmux rename-window $remote
   fi
    command ssh $@
   if [[ $renamed == 1 ]]; then
       tmux rename-window "$old_name"
   fi
} # }}}
