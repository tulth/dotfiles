#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export STEAM_FRAME_FORCE_CLOSE=1

PATH=$HOME/.local/bin:$PATH

export _JAVA_AWT_WM_NONREPARENTING=1
export LC_ALL=C

alias emacs='emacsclient -n -a "emacs" '
