# ~/.bashrc
[[ $- != *i* ]] && return
[ -f /opt/miniconda3/etc/profile.d/conda.sh ] && source /opt/miniconda3/etc/profile.d/conda.sh
EDITOR=/usr/bin/nvim
PS1='[\u@\h \W]\$ '
alias ls='ls --color=auto'
alias grep='grep --color=auto'
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
export MANPAGER='nvim +Man!'
source /usr/share/nvm/init-nvm.sh

