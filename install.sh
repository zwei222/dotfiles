#!/bin/bash

set -euo pipefail

set_env_var() {
  UNAME=$(uname)

  if [ ${UNAME} = "Darwin" ]; then
    OS="macOS"
  elif [ ${UNAME} = "Linux" ]; then
    OS_RELEASE=/etc/os-release

    if grep -e '^NAME="Ubuntu' ${OS_RELEASE} > /dev/null; then
      OS="Ubuntu"
    elif grep -e '^NAME="CentOS' ${OS_RELEASE} > /dev/null; then
      OS="CentOS"
    else
      echo "This platform is not supported."
      exit 1
    fi
  else
    echo "This platform is not supported."
    exit 1
  fi

  ROOT_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)
  REPOSITORY_DIR="${HOME}/dotfiles"
  REPOSITORY="https://github.com/zwei222/dotfiles.git"
  DOTFILES_DIR="${REPOSITORY_DIR}/dotfiles"
  ZPLUG_DIR="${HOME}/.zplug"
  ANYENV_DIR="${HOME}/.anyenv"
  ANYENV="${ANYENV_DIR}/bin/anyenv"
  PYENV_DIR="${ANYENV_DIR}/envs/pyenv"
  PYENV="${PYENV_DIR}/bin/pyenv"
  PYENV_VIRTUALENV="${PYENV_DIR}/plugins/pyenv-virtualenv"
}

install_required() {
  if [ ${OS} = "macOS" ]; then
    if ! type "brew" > /dev/null; then
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    brew install git
    brew install zsh
    brew install zplug
    brew install colordiff
    brew install neovim
  elif [ ${OS} = "Ubuntu" ]; then
    sudo apt install -y build-essential libbz2-dev libdb-dev libreadline-dev libffi-dev libgdbm-dev liblzma-dev libncursesw5-dev libsqlite3-dev libssl-dev zlib1g-dev uuid-dev tk-dev
    sudo apt install -y git
    sudo apt install -y zsh
    sudo apt install -y colordiff

    if [ ! -e ${ZPLUG_DIR} ]; then
      curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    fi

    sudo apt install -y software-properties-common
    sudo add-apt-repository ppa:neovim-ppa/stable -y
    sudo apt update
    sudo apt install -y neovim
  elif [ ${OS} = "CentOS" ]; then
    sudo yum install -y git
    sudo yum install -y zsh
    sudo yum install -y colordiff

    if [ ! -e ${ZPLUG_DIR} ]; then
      curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    fi

    sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    sudo yum install -y neovim
  fi

  if [ ! -e ${ANYENV_DIR} ]; then
    git clone https://github.com/anyenv/anyenv ${ANYENV_DIR}
    ${ANYENV} install --force-init
  fi

  ${ANYENV} install -s pyenv
  export PATH=${PYENV_DIR}/bin:${PATH}
  eval "$(pyenv init -)"
  PYTHON3=$(${PYENV} install -l | grep -v '[a-zA-Z]' | grep -e '\s3\.?*' | tail -1)
  ${PYENV} install -s ${PYTHON3}
  ${PYENV} global ${PYTHON3}

  if [ ! -e ${PYENV_VIRTUALENV} ]; then
    git clone https://github.com/yyuu/pyenv-virtualenv.git ${PYENV_DIR}/plugins/pyenv-virtualenv
  fi

  ${PYENV} virtualenv-init -
  export PATH=${PYENV_DIR}/bin:${PATH}
  ${PYENV} virtualenv ${PYTHON3} neovim3
  ${PYENV} activate neovim3
  pip install -I neovim
}

clone_dotfiles() {
  if [ -e ${DOTFILES_DIR} ]; then
    local path=$(pwd)
    cd ${REPOSITORY_DIR}
    git pull
    cd ${path}
  else
    git clone ${REPOSITORY} ${REPOSITORY_DIR}
  fi
}

install_anyenv_plugins() {
  local plugins="${ANYENV_DIR}/plugins"

  if [ ! -e ${plugins} ]; then
    git clone https://github.com/znz/anyenv-update.git ${plugins}/anyenv-update
  fi
}

create_exclusive_dotfiles() {
  touch ${DOTFILES_DIR}/.zshrc_exclusive
}

deploy_dotfiles() {
  cd ${DOTFILES_DIR}

  for dotfile in .??*; do
    ln -sfn ${DOTFILES_DIR}/${dotfile} ${HOME}/${dotfile}
  done
}

main() {
  set_env_var
  install_required
  clone_dotfiles
  install_anyenv_plugins
  create_exclusive_dotfiles
  deploy_dotfiles

  exit 0
}

main
