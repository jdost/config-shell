#/bin/sh

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

conv() {
   echo -n > $2
   while read line; do
      eval echo "$line" >> $2
   done < "$1"
}

echoIfNot() {
   if [ -d $1 ]; then
      if [ ! -d $2 ]; then
         echo "Converting ", $1
         conv $PWD/$1 $2
      fi
   else
      echo "Converting ", $1
      conv $PWD/$1 $2
   fi
}

buildHZSH() {
   if [ $(which ghc) =~ "/bin" ]; then # has ghc
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
   echoIfNot git/gitconfig $HOME/.gitconfig
   linkIfNot git/gitignore $HOME/.gitignore
   linkIfNot ack/ackrc $XDG_CONFIG_HOME/ackrc
   linkIfNot mutt $HOME/.mutt
   linkIfNot weechat $HOME/.weechat
   linkIfNot irssi $HOME/.irssi
   linkIfNot ncmpcpp $XDG_CONFIG_HOME/.ncmpcpp
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

if [[ -z "${1}" ]]; then
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
      [[ ${which pacman} =~ "/bin" ]] && build_arch
      [[ ${which apt-get} =~ "/bin" ]] && build_ubuntu
      link
      ;;
   'update')
      [[ ${which pacman} =~ "/bin" ]] && update_arch
      [[ ${which apt-get} =~ "/bin" ]] && update_ubuntu
      link
      ;;
   'link')
      link
      ;;
esac
