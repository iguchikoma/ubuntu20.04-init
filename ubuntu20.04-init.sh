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

# Setup Docker
# ref: https://docs.docker.com/engine/install/ubuntu/
function setup-docker(){

  sudo apt-get remove docker docker-engine docker.io containerd runc
  sudo apt-get update
  sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io

}

# Setup to enable non sudo docker command
# ref: https://docs.docker.com/engine/install/linux-postinstall/
function setup-non-sudo-docker(){

  sudo usermod -aG docker $USER

}

# Configure Docker to start on boot
# ref: https://docs.docker.com/engine/install/linux-postinstall/
function configure-docker-to-start-on-boot(){

  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service

}

# Configure Docker logrotate
# ref: https://docs.docker.com/config/containers/logging/json-file/
function configure-docker-logrotate() {

  ls /etc/docker/daemon.json ||\
  sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

}

# Setup Docker compose
# ref: https://docs.docker.com/compose/install/
function setup-docker-compose(){

  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose

}

# Main Function
function main() {
  : "Start to configure ubuntu20.04"

  update-packages
  setup-util
  setup-git
  setup-ls-color
  setup-pyenv
  setup-docker
  setup-non-sudo-docker
  configure-docker-to-start-on-boot
  configure-docker-logrotate
  setup-docker-compose

  : "Done for the configuration for ubuntu20.04"
}

main
