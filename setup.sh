#/bin/sh

set -euo pipefail

# Ensure this path is set
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

####################################################################################
# Linking {{{
linkIfNot() {
   [[ -e $2 ]] && return

   if [[ ! -d "$(dirname $2)" ]]; then
      echo "Creating directory: $(dirname $2)"
      mkdir -p "$(dirname $2)"
   fi

   echo "Linking " $1
   ln -s $PWD/$1 $2
}

installed() {
   pacman -Q "$1"
}

buildHZSH() {
   if installed ghc; then
      ghc -dynamic zsh/plugins/hzsh_path.src/zsh_path.hs -o zsh/plugins/hzsh_path
   else
      echo "ERROR: please install 'ghc'..."
   fi
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
   linkIfNot gem/gemrc $HOME/.gemrc
   linkIfNot npm/npmrc $XDG_CONFIG_HOME/npmrc
   linkIfNot pip/pip.conf $XDG_CONFIG_HOME/pip.conf

   # Apps
   if installed "gnupg"; then
      linkIfNot gpg/gpg.conf $HOME/.local/gpg/gpg.conf
      linkIfNot gpg/gpg-agent.conf $HOME/.local/gpg/gpg-agent.conf
      linkIfNot gpg/scdaemon.conf $HOME/.local/gpg/scdaemon.conf
      chmod 700 $HOME/.local/gpg
   fi
   #linkIfNot screen/screenrc $HOME/.screenrc
   if installed "tmux"; then
      linkIfNot tmux/tmux.conf $HOME/.tmux.conf
      linkIfNot tmux/functions.zsh $XDG_CONFIG_HOME/zsh/settings/20-tmux.zsh
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
   installed "mutt" && linkIfNot mutt $HOME/.mutt
   installed "weechat" && linkIfNot weechat $XDG_CONFIG_HOME/weechat
   installed "irssi" && linkIfNot irssi $HOME/.irssi
   installed "ncmpcpp" && linkIfNot ncmpcpp $XDG_CONFIG_HOME/ncmpcpp
} # }}}
####################################################################################
# Install - Arch {{{
run_pacman() {
   sudo pacman -Sy
   sudo pacman -S --needed \
      tmux zsh \
      ack colordiff exa git \
      weechat \
      ncmpcpp
   sudo pacman -S --needed \
      openssh pcsclite ccid
   sudo systemctl enable --now pcsclite.service
}

build_arch() {
   run_pacman
   git submodule init
   git submodule update
   for dir in $LOCAL_DIRS; do
      mkdir -p $HOME/.local/$dir
   done
   touch zsh/settings/10-directories.zsh
}

update_arch() {
   git pull
   git submodule -q foreach git pull -q origin master
   run_pacman
   link
} # }}}
####################################################################################

if [ -z "${1}" ]; then
   echo "Missing action. Syntax: ${0} [command]"
   echo "  Options:"
   echo "    init    -- installs associated programs and creates all symlinks"
   echo "    update  -- updates packages associated with repo, creates any new symlinks"
   echo "    link    -- create symlinks for files (will not overwrite existing files"
   echo "    build   -- rebuild the haskell pretty directory printer"
   echo ""
   exit 1
fi

case "${1:-init}" in
   'init')
      build_arch
      link
      ;;
   'update')
      update_arch
      link
      ;;
   'link')
      link
      ;;
   'build')
      buildHZSH
      ;;
esac
