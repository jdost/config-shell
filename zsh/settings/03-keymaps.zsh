# Key bindings
bindkey "^[[7~"  beginning-of-line    # Home
bindkey "^[[8~"  end-of-line          # End
bindkey "^[[5~"  beginning-of-history # PageUp
bindkey "^[[6~"  end-of-history       # PageDown
bindkey "^[[3~"  delete-char          # Del
bindkey "^[0c"   forward-word         # Ctrl + Right
bindkey "^[0d"   backward-word        # Ctrl + Left
bindkey "^[0c~"  beginning-of-line

# vim bindings
bindkey -M vicmd "/" history-incremental-search-backward
bindkey -M vicmd "?" history-incremental-search-forward
bindkey -M vicmd "//" history-beginning-search-backward
bindkey -M vicmd "??" history-beginning-search-forward

bindkey -M vicmd "q" push-line
bindkey -M vicmd "!" edit-command-output
