PS1=" [%F{green}%n@%m%f %1~ %#] $ "

# history time stamp format
HIST_STAMPS="mm/dd/yyyy"

# homebrew formulae
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

# zsh vi mode
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_INIT_MODE=sourcing

# source configs
alias sz="source $HOME/.zshrc && source $HOME/.zshenv"

# open files/dirs
alias home="cd ~"
alias sys="cd $NOTES/systemvetenskap"
alias kur="cd $KURSER"
alias ec="emacsclient -c -n -a ''"

# other
alias cfg='/usr/bin/git --git-dir=/Users/najjt/.cfg/ --work-tree=/Users/najjt'
alias x="exit"
alias ..="cd .."
alias ls='ls -lh --color=always'
alias pwdc="pwd | pbcopy"       # copies current working directory to system clipboard
alias pi="ssh pi@192.168.1.48"  # ssh to raspberry pi
alias wt="curl wttr.in"         # weather forecast
alias python="python3"
alias tmc="~/tools/tmc/tmc"

export PATH="/opt/homebrew/bin:$PATH"
