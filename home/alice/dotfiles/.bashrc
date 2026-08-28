alias tt='vim ~/Documents/new-2.md'
alias ly='lynx -cookies'

ghi(){
	firefox https://www.github.com/isaacemilien/$1/issues/new &
}

yt(){
	pls "ytsearch50:$1"
}

set -o vi

export PATH="$HOME/.local/bin:$PATH"
