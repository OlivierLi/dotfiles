# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# This makes cd=pushd
setopt autopushd pushdminus pushdsilent pushdtohome

#Aliases
alias "ls"="ls --color=auto"
alias "ll"="ls -lrt"
alias "up"="sudo apt-get update && sudo apt-get upgrade"
alias "install"="sudo apt-get install"
alias "history"="history 1"

autoload -U compinit promptinit colors
autoload -Uz vcs_info

# bind special keys according to readline configuration
eval "$(sed -n 's/^/bindkey /; s/: / /p' /etc/inputrc)" > /dev/null

# set zsh in emacs mode
bindkey -e

setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt prompt_subst

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

#Environement variables
export EDITOR="/usr/bin/vim"

PS1="%(!.${FG_BRIGHT_RED}.${FG_BRIGHT_GREEN})%n@%m${COLOR_RESET}:${FG_BRIGHT_BLUE}%1~${COLOR_RESET}%(!.#.$) "

#Custom auto-completions
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
