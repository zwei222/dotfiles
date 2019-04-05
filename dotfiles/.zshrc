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
    PROMPT="%{[$[31]m%}%B$LOGNAME@%m[%W %T]:%b%{[m%} %h# "
    RPROMPT="[%{[31m%}%~%{[m%}]"
    PATH=${PATH}:/sbin:/usr/sbin:/usr/local/sbin
    HOME=/root
else
    PROMPT="%{[$[32+$RANDOM % 5]m%}$LOGNAME@%m%B[%W %T]:%b%{[m%} %h%% "
    RPROMPT="[%{[33m%}%~%{[m%}]"
fi

# load zplug config
source ~/.zplug/init.zsh

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
alias mv="mv -ir"
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

# zstyle
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:*' formats '%F{green}(%b)'
zstyle ':vcs_info:git:*' unstagedstr '%F{red}+'
zstyle ':vcs_info:git:*' stagedstr '%F{yellow}!'

# function
## cd with fzf
cdf() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "${dir}"
}

## pre-prompt command
precmd() {
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

