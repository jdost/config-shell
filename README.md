# Terminal configurations

These are the configuration files (aka "dot files") for various terminal based 
applications that I use normally (or have used).  These should all be able to be
used without an X server running.  I have a `vim` config, but it was large enough
and changed enough that I am putting it in its own repo.

## Applications

`zsh ack git tmux screen weechat mutt irssi ncmpcpp`

## Setup

Included is a script to setup and manage the configs.  To call it, just run: 
`./setup.sh init` to install the applications (some are commented out) and link the
configs in this repo to the home locations (NOTE: it will not overwrite any files
that already exist there).  This is currently geared towards Arch Linux, over time,
I hope to include other distros to this.  You can also just run `./setup.sh link`
to link the files without installing anything.

## `gitconfig`

The `.gitconfig` file in your home directory will have some fields empty (I don't
think you want them to default to my credentials) so you should probably open that
file up and make sure that everything is correctly set.
