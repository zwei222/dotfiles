#!/bin/bash

set -eu

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
  DOTFILES_DIR="${ROOT_DIR}/dotfiles"
  ZPLUG_DIR="~/.zplug"
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
  elif [ ${OS} = "Ubuntu" ]; then
    sudo apt install -y git
    sudo apt install -y zsh
    sudo apt install -y colordiff

    if [ ! -e ${ZPLUG_DIR} ]; then
      curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    fi
  elif [ ${OS} = "CentOS" ]; then
    sudo yum install -y git
    sudo yum install -y zsh
    sudo yum install -y colordiff

    if [ ! -e ${ZPLUG_DIR} ]; then
      curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    fi
  fi
}

deploy_dotfiles() {
  cd ${DOTFILES_DIR}

  for dotfile in .??*; do
    ln -sfn ${DOTFILES_DIR}/${dotfile} ~/${dotfile}
  done
}

main() {
  set_env_var
  install_required
  deploy_dotfiles

  exit 0
}

main
