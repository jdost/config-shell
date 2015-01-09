# Terminal configurations

These are the configuration files (aka "dot files") for various terminal based 
applications that I use normally (or have used).  These should all be able to be
used without an X server running.  I have a `vim` config, but it was large enough
and changed enough that I am putting it in its own repo.

## Applications

`zsh ack git tmux screen weechat mutt ncmpcpp`

## Setup

Included is a script to setup and manage the configs.  To call it, just run: 
`./setup.sh init` to install the applications (some are commented out) and link the
configs in this repo to the home locations (NOTE: it will not overwrite any files
that already exist there).  This is currently geared towards Arch Linux, over time,
I hope to include other distros to this.  You can also just run `./setup.sh link`
to link the files without installing anything.

## Scripts & Stuff

There are a few functions and scripts.  Under `tmux/functions.zsh` there are some
aliases that will get symlinked into the zsh folder to allow some sensible usage for
tmux in regards to attaching to sessions and such.  The `git-subrm` script and the
`git-pair` scripts should be symlinked into your path and add on some git 
subcommands that add some functionality I have found useful.  `git pair` will take
a list of names passed in as arguments and generate a local git username that is the
global git username and the provided usernames in a sorted, "and" separated list.
The `git-subrm` script attempts to remove a git submodule from both the repo files
and the actual directory.
