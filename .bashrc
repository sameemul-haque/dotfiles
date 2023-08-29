alias config='/usr/bin/git --git-dir=/home/sam/.dotfiles/ --work-tree=/home/sam'
# Enable the subsequent settings only in interactive sessions
case $- in
  *i*) ;;
    *) return;;
esac
#####---------- EXPORTS ----------###
export BROWSER="firefox"
export EDITOR="vim"
export VISUAL="vim"
export MYVIMRC="$HOME/vim/.vimrc"
export VIMINIT="source $MYVIMRC"
export LESSHISTFILE=-
export HISTFILE="$HOME/.bash_history"
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
export CDPATH=".:$HOME:$HOME/.config/:$HOME/.local/:$HOME/.local/share/:$HOME/.local/programs"
export LIBVIRT_DEFAULT_URI='qemu:///system'
export CSCOPE_EDITOR="vim"

alias ls='ls --color=auto'
alias ll='ls -alh --color=auto'
alias grep='grep --color=auto'
alias neofetch='neofetch --ascii ~/.config/neofetch/arch'

###---------- SHELL OPTIONS -------###

#neofetch
###---------- DECORATION ----------###
#logo
#case "$TERM" in
    #kitty)
        #kitty #+kitten icat --align left $HOME/Media/Pictures/logo.gif
        #printf "< "$(echo $DESKTOP_SESSION | cut -d '/' -f 5)" SYS INFO >\n\n" | tr '[:lower:]' '[:upper:]'
        #printf "\e[1;37m|-------------------------------------------------------------------------|\n\n"
        #cat $HOME/.local/share/sysinfo.txt; printf "\n\n"
        #printf "|-------------------------------------------------------------------------|\n\n"
        #;;
#    st-256color)
#        pfetch
#        ;;
#    alacritty)
#        neofetch
#        ;;
#esac

#printf " SYSTEM INFO ]"
#printf "\n\n"
#cat $HOME/.local/share/sysinfo.txt; printf "\n\n"

###----------------- CD COMM ------------------------###

#cd() {
#    [[ $# -eq 0 ]] && return
#    builtin cd "$@" || exit 
#}

alias lsp="lsd -a | fzfimg.sh --preview-window=bottom:75%"

###------------------- PROMPT -----------------------###

function parse_git_dirty {
  STATUS="$(git status 2> /dev/null)"
  if [[ $? -ne 0 ]]; then printf ""; return; else printf " ["; fi
  if echo "${STATUS}" | grep -c "renamed:"         &> /dev/null; then printf " >"; else printf ""; fi
  if echo "${STATUS}" | grep -c "branch is ahead:" &> /dev/null; then printf " !"; else printf ""; fi
  if echo "${STATUS}" | grep -c "new file::"       &> /dev/null; then printf " +"; else printf ""; fi
  if echo "${STATUS}" | grep -c "Untracked files:" &> /dev/null; then printf " ?"; else printf ""; fi
  if echo "${STATUS}" | grep -c "modified:"        &> /dev/null; then printf " *"; else printf ""; fi
  if echo "${STATUS}" | grep -c "deleted:"         &> /dev/null; then printf " -"; else printf ""; fi
  printf " ]"
}

parse_git_branch() {
  # Long form
  git rev-parse --abbrev-ref HEAD 2> /dev/null
 # Short form
  # git rev-parse --abbrev-ref HEAD 2> /dev/null | sed -e 's/.*\/\(.*\)/\1/'
}

prompt_comment() {
    DIR="$HOME/.local/share/promptcomments/"
    MESSAGE="$(find "$DIR"/*.txt | shuf -n1)"
    cat "$MESSAGE"
}

#PS1="\e[00;36m\]┌─[ \e[00;37m\]\T \d \e[00;36m\]]──\e[00;31m\]>\e[00;37m\] \u\e[00;31m\]@\e[00;37m\]\h\n\e[00;36m\]|\n\e[00;36m\]└────\e[00;31m\]> \e[00;37m\]\w \e[00;31m\]\$ \e[01;37m\]"
# PS1="\[\e[01;37m\]{ \[\e[01;34m\]\w \[\e[01;37m\]} \[\e[01;35m\]\[\$ \]\[\e[01;37m\]"
#PS1="\[\e[1;36m\]\$(parse_git_branch)\[\033[31m\]\$(parse_git_dirty)\[\033[00m\]\n\w\[\e[1;31m\] \[\e[1;36m\]\[\e[1;37m\] "PS1="\[\e[1;33m\]\$(parse_git_branch)\[\033[34m\]\$(parse_git_dirty)\n\[\033[1;36m\]  \[\e[1;37m\] \w \[\e[1;37m\]\[\e[0;37m\] "
PS1="\[\e[1;33m\]\$(parse_git_branch)\[\033[34m\]\$(parse_git_dirty)\n\[\033[1;34m\] 󰣇 \[\e[1;37m\] \w \[\e[1;36m\]\[\e[0;37m\] "

###---------- ARCHIVE EXTRACT ----------###

ex ()
{
    if [ -f $1 ] ; then
      case $1 in
        *.tar.bz2)   tar xjf $1   ;;
        *.tar.gz)    tar xzf $1   ;;
        *.bz2)       bunzip2 $1   ;;
        *.rar)       unrar x $1   ;;
        *.gz)        gunzip $1    ;;
        *.tar)       tar xf $1    ;;
        *.tbz2)      tar xjf $1   ;;
        *.tgz)       tar xzf $1   ;;
        *.zip)       unzip $1     ;;
        *.Z)         uncompress $1;;
        *.7z)        7za e x $1   ;;
        *.deb)       ar x $1      ;;
        *.tar.xz)    tar xf $1    ;;
        *.tar.zst)   unzstd $1    ;;
        *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}


### ---------- OTHER ----------###

HISTSIZE=10000
#SAVEHIST=10000

export LESS_TERMCAP_mb=$'\e[1;36m'
export LESS_TERMCAP_md=$'\e[1;36m'
export LESS_TERMCAP_me=$'\e[1;37m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;34m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;34m'

#eval "$(zoxide init bash)"

# BEGIN_KITTY_SHELL_INTEGRATION
# if test -n "$KITTY_INSTALLATION_DIR" -a -e "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; then source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"; fi
# END_KITTY_SHELL_INTEGRATION

# Generated for envman. Do not edit.
# [ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
