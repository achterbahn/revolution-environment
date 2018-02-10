# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

RESET_ALL=`tput sgr0`

FG_RED=`tput setaf 1`
FG_GREEN=`tput setaf 2`
FG_YELLOW=`tput setaf 3`
FG_BLUE=`tput setaf 4`
FG_MAGENTA=`tput setaf 5`
FG_CYAN=`tput setaf 6`
FG_WHITE=`tput setaf 7`

BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_BLUE=`tput setab 4`
BG_WHITE=`tput setab 7`

UL=`tput smul`
RUL=`tput rmul`
BOLD=`tput bold`

echo "${FG_BLUE}${BOLD}"

echo "###################################################"
echo "#       Hello SEDA.digital Vagrant User!          #"
echo "###################################################"

echo "${RESET_ALL}"

#grep "Host\s" ~/.ssh/config
#grep "Host\s" ~/.ssh/config | awk -v mark="${FG_GREEN}" -v reset="${RESET_ALL}" '{printf "%s%-30s%s(%s)\n", mark, $2, reset, $3 " " $4 " " $5}'

echo "${FG_CYAN}"
echo "You are now redirected to the vagrant synced folder."
echo "Don't forget to use ${UL}sudo${RUL} if you want to make changes there! Manipulation using host synced folder ist preferred."
echo ""

cd /vagrant/

echo "${RESET_ALL}"
