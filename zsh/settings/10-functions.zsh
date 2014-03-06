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

# vim: ft=zsh:foldmethod=marker
