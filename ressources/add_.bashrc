
### Config perso

alias ll='ls -alh'
alias l='ll'
alias lrt='ls -alhrt'
alias lt='lrt'
alias vi='vim'
alias dos2unix='fromdos'
alias unix2dos='todos'

alias dps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}\t{{.Status}}"'

### export DISPLAY
export DISPLAY=`who -m | awk -F"-" '{print $6"."$7"."$8"."$9}' | awk -F'.' '{print $1"."$2"."$3"."$4}'`:0.0
