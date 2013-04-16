reload () { source $ZSHRC }

# creates a custom name for the current directory {{{
namedir () {
   echo "$1=$PWD ;  : ~$1" >> $ZSH_SETTINGS_DIR/$ZSH_DIR_FILE
   . $ZSH_SETTINGS_DIR/$ZSH_DIR_FILE
} # }}}
export ZSH_DIR_FILE="10-directories.zsh"
# ft=zsh foldmethod=marker
