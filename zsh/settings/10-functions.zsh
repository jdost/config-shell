reload () { source $ZSHRC }
function '#' () { }

# most used commands {{{
mostused () {
   sed -n 's/^\([a-z]*\) .*\1//p' $HISTFILE | sort | uniq -c | sort -n -k1 |
      tail -25 | tac
}
# }}}

# try x times until success {{{
try () {
   local COUNT=-1
   if [[ $1 =~ ^[0-9]+$ ]]; then
      COUNT=$1
      shift
   fi

   local STATUS=0

   while [ "$COUNT" -ne 0 ]; do
      let COUNT-=1
      $*
      STATUS=$?
      if [ $STATUS -eq 0 ]; then
         break
      fi
   done
}
# }}}

# store website offline {{{
export OFFLINE_LOC=$HOME/downloads/offline
offline () {
   local originDir=$PWD
   cd $OFFLINE_LOC

   local dirName=`print "$1" | sed "s/\//_/g"`
   mkdir "$dirName"
   cd "$dirName"

   local domain=`echo "$1" | sed "s#/.*##"`
   wget --recursive \
      --no-clobber \
      --page-requisites \
      --html-extension \
      --convert-links \
      --domains $domain \
      --no-parent \
         $1
   cd $originDir
}
# }}}

# Some OSX polyfills {{{
if [ -z "$(type realpath %1> /dev/null)" ]; then
   realpath() {
      [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
   }
fi # }}}

# creates a custom name for the current directory {{{
export ZSH_DIR_FILE="10-directories.zsh"
namedir () {
   echo "$1=$PWD ;  : ~$1" >> $ZSH_SETTINGS_DIR/$ZSH_DIR_FILE
   . $ZSH_SETTINGS_DIR/$ZSH_DIR_FILE
} # }}}

# Terminal color tests {{{
color () {
   for i; do
      print -P -- "\033[48;5;${i}m $i \033[0m"
   done
} # }}}

# Notify {{
notify () {
   case "$1" in
      "1") local URGENCY="low"
           shift ;;
      "2") local URGENCY="normal"
           shift ;;
      "3") local URGENCY="critical"
           shift ;;
      *)   local URGENCY="normal"
   esac

   local NAME=$1
   shift

   if command -v notify-send >/dev/null 2>&1 ; then # has notify-send
      notify-send -u $URGENCY -a $0 "$NAME" "$*"
   fi

   echo -e "\a"
} # }}}

# vim: ft=zsh:foldmethod=marker
