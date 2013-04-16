local -a VIDEO VIM IMG PDF
# Vim file extensions {{{
VIM=(
   awk
   bash
   c
   cfg
   conf
   cpp
   css
   diff
   example
   git
   gitconfig
   gitignore
   hs
   htm
   html
   ini
   java
   js
   json
   less
   log
   lua
   markdown
   md
   nfo
   pacnew
   patch
   PKGBUILD
   pl
   py
   rb
   scss
   signature
   tex
   txt
   vim
   viminfo
   xml
   yml
   zsh
)
# }}}
# Video file extensions {{{
VIDEO=(
   avi
   cue
   dat
   fcm
   flac
   flv
   m3u
   m4
   m4a
   m4v
   mkv
   mov
   mp3
   mp4
   mpeg
   mpg
   ogg
   ogm
   ogv
   rmvb
   sample
   spl
   ts
   wmv
)
# }}}
# Image file extensions {{{
IMG=(
   bmp
   cdr
   gif
   ico
   jpeg
   jpg
   png
   svg
   xpm
)
# }}}
# PDF file extensions {{{
PDF=(
   pdf
)
# }}}
# Apply the aliases {{{
#alias -s $^VIM="vim --"
alias -s $^VIDEO="video --"
alias -s $^IMG="feh -FZ --"
alias -s $^PDF="pdf"
# }}}

# global aliases {{{
alias -g ...=../..
alias -g ....=../../..
alias -g .....=../../../..
# }}}

# vim: ft=zsh foldmethod=marker
