stty -ixon

export VISUAL="vim"
export FZF_DEFAULT_COMMAND="rg --files --no-ignore-vcs -g "!out""
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
  git checkout main
  git pull origin main
  gclient sync -D
  autoninja -C out/Release/ chrome
  ninja -C ~/git/chromium/src/out/Release  -t compdb cxx cc > compile_commands.json
}

csv () {
  csvlook $1 | vim -
}

csv_sort () {
  csvsort -c $2 $1 | csvlook | vim -
}
