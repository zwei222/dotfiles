# use escape sequence
setopt prompt_subst

# default encoding
export LANG=ja_JP.UTF-8
export KCODE=u

# environment variables
export EDITOR="vim"
export LSCOLORS=Exfxcxdxbxegedabagacad
export LS_COLORS="di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30"
export ZLS_COLORS=${LS_COLORS}
export CLICOLOR=true
export TERM=xterm-256color

## anyenv
export PATH="${HOME}/.anyenv/bin:${PATH}"
eval "$(anyenv init -)"

## pyenv
eval "$(pyenv virtualenv-init -)"

## prompt
if [ ${USER} = "root" ] 
then
    PROMPT="%{[$[31]m%}%B$LOGNAME@%m[%D %T]:%b%{[m%} %h# "
    RPROMPT="[%{[31m%}%~%{[m%}]"
    PATH=${PATH}:/sbin:/usr/sbin:/usr/local/sbin
    HOME=/root
else
    PROMPT="%{[$[32+$RANDOM % 5]m%}$LOGNAME@%m%B[%D %T]:%b%{[m%} %h%% "
    RPROMPT="[%{[33m%}%~%{[m%}]"
fi

# load zplug config
source ~/.zplug/init.zsh

# load exclusive .zshrc
source ~/.zshrc_exclusive

# enabled prompt color
autoload -Uz colors
colors

# enabled auto-complete
autoload -U compinit
compinit

# enabled vcs_info
autoload -Uz vcs_info
setopt prompt_subst
RPROMPT=${vcs_info_msg_0_}$RPROMPT

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000000
SAVEHIST=10000000
setopt hist_expand
setopt extended_history
setopt inc_append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_verify

# alias
alias cp="cp -ir"
alias mv="mv -i"
alias rm="rm -ir"

case ${OSTYPE} in
  darwin*)
    alias ls="ls -G"
    ;;
  linux*)
    alias ls="ls --color=auto"
    ;;
esac

alias ll="ls -l"
alias lt="ls -lt"
alias la="ls -lhAF"
alias ps="ps aux"
alias lsf="ls | fzf"
alias llf="ls -l | fzf"
alias laf="ls -lhAF | fzf"
alias diff="colordiff -u"
alias reload="exec ${SHELL} -l"

if type "nvim" > /dev/null; then
  alias vim="nvim"
fi

# suffix alias
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract

# zstyle
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:*' formats '%F{green}(%b)'
zstyle ':vcs_info:git:*' unstagedstr '%F{red}+'
zstyle ':vcs_info:git:*' stagedstr '%F{yellow}!'

# function
## display all history
function history-all() {
  history -E 1
}

## cd with fzf
function cdf() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "${dir}"
}

## mkdir and cd
function mcd() {
  mkdir -p "$@" && eval cd "\"\$$#\"";
}

## extract compressed file
function extract() {
  case $1 in
    *.tar.gz|*.tgz) tar xzvf $1;;
    *.tar.xz) tar Jxvf $1;;
    *.zip) unzip $1;;
    *.lzh) lha e $1;;
    *.tar.bz2|*.tbz) tar xjvf $1;;
    *.tar.Z) tar zxvf $1;;
    *.gz) gzip -d $1;;
    *.bz2) bzip2 -dc $1;;
    *.Z) uncompress $1;;
    *.tar) tar xvf $1;;
    *.arj) unarj $1;;
  esac
}

## pre-prompt command
function precmd() {
  vcs_info
}

# zplug
## require plugins
zplug "zsh-users/zsh-syntax-highlighting"
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf
zplug "mollifier/anyframe"

## confirm not installed plugins
if ! zplug check --verbose; then
  printf "Install? [y/N]:"
  if read -q; then
    echo; zplug install
  fi
fi

zplug load

