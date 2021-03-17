#*************************************************************************************************#
# Copyright by @bkozdras <b.kozdras@gmail.com>                                                    #
# Purpose: ~/.bashrc to set initial settings of /bin/bash shell on connection to container.       #
# Version: 1.0                                                                                    #
# Licence: MIT                                                                                    #
#*************************************************************************************************#

#!/bin/bash

force_color_prompt=yes

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
bold=$(tput bold)
dim=$(tput dim)
off=$(tput sgr0)
thumb () {
    case $1 in
        0) printf "\xF0\x9F\x91\x8d" ;;
        *) printf "\xF0\x9F\x91\x8e  $red($1)$off" ;;
    esac
}
case "$SUDO_USER" in
    "") prompt="$" ;;
    *) prompt="$red$bold#$off" ;;
esac
export PS1="$yellow$dim\u@\h [\w] \$(thumb \$?)$off \n$prompt "
