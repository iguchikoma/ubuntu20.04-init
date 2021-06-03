#!/bin/bash
set -uvx

# Update installed packages
function update-packages() {
  sudo apt update && sudo apt upgrade -y
}

# Setup utility
function setup-util() {
  sudo apt update
    sudo apt install -y tree
}

# Setup git
# Ref: https://qiita.com/noraworld/items/8546c44d1ec6d739493f
function setup-git() {

  ls ~/.git-prompt.sh ||\
  ( wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh &&\
  mv git-prompt.sh ~/.git-prompt.sh )

  git config --global user.email "iguchi.t@gmail.com"
  git config --global user.name "Takashi Iguchi"
  grep '# git config' ~/.bashrc ||\
  cat <<'EOF' >>~/.bashrc
# git config
. ~/.git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\033[32m\]\u@\h\[\033[00m\]:\[\033[34m\]\w\[\033[31m\]$(__git_ps1)\[\033[00m\]\$ '
EOF

}

# Setup ls color
# Memo: For easy to see, install ls color
function setup-ls-color() {

  ls ~/.dircolors ||\
  ( wget https://raw.githubusercontent.com/seebi/dircolors-solarized/master/dircolors.ansi-universal &&\
  mv dircolors.ansi-universal ~/.dircolors )

  grep '# ls color config' ~/.bashrc ||\
  cat <<'EOF' >>~/.bashrc
# ls color config
if [ -f ~/.dircolors ]; then
    if type dircolors > /dev/null 2>&1; then
        eval $(dircolors ~/.dircolors)
    fi
fi
EOF

}

# Setup pyenv
function setup-pyenv() {

  sudo apt install -y \
  build-essential \
  libffi-dev \
  libssl-dev \
  zlib1g-dev \
  liblzma-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  git

  ls ~/.pyenv ||\
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv

  grep '# pyenv init' ~/.bashrc ||\
  cat <<'EOF' >>~/.bashrc
# pyenv init
# ref: https://github.com/pyenv/pyenv
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/bin:$PATH
eval "$(pyenv init --path)"
EOF

}

# Main Function
function main() {
  : "Start to configure ubuntu20.04"

  update-packages
  setup-util
  setup-git
  setup-ls-color
  setup-pyenv

  : "Done for the configuration for ubuntu20.04"
}

main
