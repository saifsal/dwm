# ~/.bashrc
[[ $- != *i* ]] && return
EDITOR=/usr/bin/nvim
PS1='[\u@\h \W]\$ '
alias ls='ls --color=auto'
alias grep='grep --color=auto'
export MANPAGER='nvim +Man!'

