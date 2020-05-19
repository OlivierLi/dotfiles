stty -ixon

export VISUAL="vim"
export FZF_DEFAULT_COMMAND="rg --files"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

alias format="git cl format"
alias ack=rg

commit () {
  git cl format
  git add -u
  git commit -m "$1"
}

upload() {
  commit "$1"
  git cl upload
}

pull () {
  git checkout master
  git pull origin master
  gclient sync 
  ninja -C ~/git/chromium/src/out/Default  -t compdb cxx cc > compile_commands.json
}
