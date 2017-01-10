# This makes cd=pushd
setopt autopushd pushdminus pushdsilent pushdtohome

#Aliases
alias "ls"="ls --color=auto"
alias "ll"="ls -lrt"
alias "up"="sudo apt-get update && sudo apt-get upgrade"
alias "install"="sudo apt-get install"
alias "remove"="sudo apt-get remove"
alias "ack"="ack-grep"
alias "history"="history 1"
alias "redshift-night"="redshift -O 4000 -l 45.133315:-71.819000 -b 0.5"
alias "redshift-late-night"="redshift -O 3000 -l 45.133315:-71.819000 -b 0.3"
alias "redshift-day"="redshift -O 5500 -l 45.133315:-71.819000 -b 1.0"

#If no session named default exists start one. If it does exist attach to it.
# -2 and TERM to fix colors in vim
alias "tmux-launch"="TERM=xterm-256color;tmux -2 attach -t default || tmux -2  new -s default"
#Start tmux in a new session but sharing the windows of the default session.
#Usefull to use multiple monitors
alias "tmux-multi"="TERM=xterm-256color;tmux -2 new-session -t default || tmux -2  new -s default"

autoload -U compinit promptinit colors
autoload -Uz vcs_info

# bind special keys according to readline configuration
eval "$(sed -n 's/^/bindkey /; s/: / /p' /etc/inputrc)" > /dev/null
#Special bindkeys for TMUX
bindkey '^R' history-incremental-search-backward

#disable input pausing/restarting
stty -ixon

setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt prompt_subst

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

#Custom auto-completions
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
