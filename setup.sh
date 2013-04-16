#/bin/sh

if [ -z $XDG_CONFIG_HOME ]; then
   XDG_CONFIG_HOME = $HOME/.config
fi

####################################################################################
# Linking {{{
linkIfNot() {
   if [ -d $1 ]; then
      if [ ! -d $2 ]; then
         echo "Linking " $1
         ln -s $PWD/$1 $2
      fi
   elif [ ! -e $2 ]; then
      echo "Linking " $1
      ln -s $PWD/$1 $2
   fi
}

buildHZSH() {
   if type ghc > /dev/null ; then # has ghc
      ghc zsh/plugins/hzsh_path.src/zsh_path.hs -o zsh/plugins/hzsh_path
   fi
}

link() {
   # Shell/Environment
   linkIfNot environment/term $HOME/.local/environment/term
   linkIfNot shell $XDG_CONFIG_HOME/zsh
   linkIfNot shell/zshrc $HOME/.zshrc
   buildHZSH
   #linkIfNot environment/env_def $HOME/.env/def

   # Apps
   linkIfNot screen/screenrc $HOME/.screenrc
   linkIfNot tmux/tmux.conf $HOME/.tmux.conf
   mkdir -p $XDG_CONFIG_HOME/git
   linkIfNot git/gitconfig $XDG_CONFIG_HOME/git/gitconfig
   linkIfNot git/gitignore $HOME/.gitignore
   linkIfNot ack/ackrc $XDG_CONFIG_HOME/ackrc
   linkIfNot mutt $HOME/.mutt
   linkIfNot weechat $HOME/.weechat
   linkIfNot irssi $HOME/.irssi
   #linkIfNot ncmpcpp $XDG_CONFIG_HOME/.ncmpcpp
} # }}}
####################################################################################
# Install - Arch {{{
aurGet() {
   cd $HOME/.aur/
   ABBR=${1:0:2}
   wget http://aur.archlinux.org/packages/$ABBR/$1/$1.tar.gz
   tar -xf "$1.tar.gz"
   rm "$1.tar.gz"
   cd "$1"
   makepkg
}

run_pacman() {
   sudo pacman -Sy
   sudo pacman -S --needed zsh
   sudo pacman -S --needed tmux git ack
   # sudo pacman -S --needed mutt weechat
   # sudo pacman -S --needed mpd ncmpcpp
   # sudo pacman -S --needed irssi
}

build_arch() {
   run_pacman
   mkdir $HOME/.bin
   mkdir $HOME/.aur
   mkdir -p $HOME/.local/environment
}

update_arch() {
   git pull
   git submodule -q foreach git pull -q origin master
   run_pacman
   link
} # }}}
####################################################################################
# Install - Ubuntu {{{
run_apt() {
   sudo apt-get update
   sudo apt-get upgrade

   sudo apt-get install zsh
   sudo apt-get install tmux git ack
   # sudo apt-get install mutt weechat
   # sudo apt-get install mpd ncmpcpp
   # sudo apt-get install irssi
}

build_ubuntu() {
   run_apt
   mkdir $HOME/.bin
   mkdir -p $HOME/.local/environment
}

update_ubuntu() {
   git pull
   git submodule -q foreach git pull -q origin master
   run_apt
} # }}}
####################################################################################

if [ -z "${1}" ]; then
   echo "Missing action. Syntax: ${0} [command]"
   echo "  Options:"
   echo "    init    -- installs associated programs and creates all symlinks"
   echo "    update  -- updates packages associated with repo, creates any new symlinks"
   echo "    link    -- create symlinks for files (will not overwrite existing files"
   echo ""
   exit 1
fi
case "${1}" in
   'init')
      type pacman > /dev/null  && build_arch
      type apt-get > /dev/null && build_ubuntu
      link
      ;;
   'update')
      type pacman > /dev/null && update_arch
      type apt-get > /dev/null && update_ubuntu
      link
      ;;
   'link')
      link
      ;;
esac
