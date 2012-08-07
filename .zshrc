#Aliases
alias "ls"="ls --color=auto"
alias "ll"="ls -lrt"

autoload -U compinit promptinit colors
autoload -Uz vcs_info

compinit
promptinit
colors

# bind special keys according to readline configuration
eval "$(sed -n 's/^/bindkey /; s/: / /p' /etc/inputrc)"

# set zsh in emacs mode
bindkey -e

setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt prompt_subst

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
