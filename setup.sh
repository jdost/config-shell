#/bin/sh

set -euo pipefail

# This may not be defined as this is the linking script that sets up the userdirs
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

show_help() {
   cat <<-HELP
Setup script for terminal configs

USAGE: ${0} [command]

commands:
   init    -- Initialize system with expected packages and linked configs
   update  -- Updates state of local repo and fixes missing links
   link    -- Create missing links not already defined
   build   -- Rebuild any local compile binaries
HELP
}

####################################################################################
# Helpers {{{
linkIfNot() {
   [[ -e "$2" ]] && return

   if [[ ! -d "$(dirname $2)" ]]; then
      echo "Creating directory: $(dirname $2)"
      mkdir -p "$(dirname $2)"
   fi

   echo "Linking " $1
   ln -s $PWD/$1 $2
}

installed() {
   pacman -Q "$1" &> /dev/null
}


buildHZSH() {
   if !which ghc &>/dev/null ; then  # ghc is not defined, don't build it
      echo "ERROR: please install 'ghc'..."
      return
   fi
   ghc \
      -dynamic $PWD/zsh/plugins/hzsh_path.src/zsh_path.hs \
      -o $PWD/zsh/plugins/hzsh_path
}

link() {
   # General session environment settings
   linkIfNot environment/term $HOME/.local/environment/term
   linkIfNot environment/general $HOME/.local/environment/general
   linkIfNot user-dirs/dirs $XDG_CONFIG_HOME/user-dirs.dirs
   # zsh specific things
   if installed "zsh"; then
      linkIfNot zsh $XDG_CONFIG_HOME/zsh
      linkIfNot zsh/zshrc $HOME/.zshrc
      buildHZSH
   fi
   # bash
   linkIfNot inputrc/inputrc $XDG_CONFIG_HOME/inputrc
   linkIfNot bash/bashrc $HOME/.bashrc
   # Language package managers
   #linkIfNot gem/gemrc $HOME/.gemrc
   #linkIfNot npm/npmrc $XDG_CONFIG_HOME/npmrc
   linkIfNot pip $XDG_CONFIG_HOME/pip

   # Apps
   if installed "gnupg"; then
      mkdir -p $HOME/.local/gpg
      linkIfNot gpg/gpg.conf $HOME/.local/gpg/gpg.conf
      linkIfNot gpg/gpg-agent.conf $HOME/.local/gpg/gpg-agent.conf
      linkIfNot gpg/scdaemon.conf $HOME/.local/gpg/scdaemon.conf
      chmod 700 $HOME/.local/gpg
   fi
   #linkIfNot screen/screenrc $HOME/.screenrc
   if installed "tmux"; then
      linkIfNot tmux/tmux.conf $HOME/.tmux.conf
      linkIfNot tmux/layouts $XDG_CONFIG_HOME/tmux
   fi
   if installed "git"; then
      if [[ "$(git --version)" > "git version 1.8.0" ]]; then
         mkdir -p $XDG_CONFIG_HOME/git
         linkIfNot git/gitconfig $XDG_CONFIG_HOME/git/config
      else
         linkIfNot git/gitconfig $HOME/.gitconfig
      fi
      linkIfNot git/gitignore $HOME/.gitignore
   fi
   installed "ack" && linkIfNot ack/ackrc $XDG_CONFIG_HOME/ackrc
   installed "weechat" && linkIfNot weechat $XDG_CONFIG_HOME/weechat
} # }}}
####################################################################################
# Actions {{{
install() {
   sudo pacman -Sy
   sudo pacman -S --needed \
      tmux zsh \
      ack colordiff exa git \
      weechat which fakeroot \
      jq man-db man-pages
   sudo pacman -S --needed \
      openssh pcsclite ccid
   #sudo systemctl enable --now pcsclite.service
}

initialize() {
   git submodule init
   git submodule update
   local localdirs=('aur' 'bin' 'environment')
   for dir in $localdirs; do
      mkdir -p $HOME/.local/$dir
   done
   touch zsh/settings/10-directories.zsh
}

update() {
   git pull
   git submodule -q foreach git pull -q origin master
} # }}}
####################################################################################

case "${1:-''}" in
   'init')
      install
      initialize
      link
      ;;
   'update')
      install
      update
      link
      ;;
   'build')
      buildHZSH
      ;;
   'link')
      link
      ;;
   *)
      show_help
      exit
      ;;
esac
