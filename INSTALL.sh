#!/bin/bash

###
#   RUN THIS WITH /bin/bash NOT /bin/sh
#   /bin/sh MAPS TO INCOMPATIBLE TERM EMULATORS
#   IN SOME OS
#
#   ```
#    $ /bin/bash INSTALL.sh
#   ```
#
###

PRODUCT="TERMINAL"

OPENING_MESSAGE="STARTING $PRODUCT CONFIGURATION INSTALL"
echo -e "\033[0;32m$OPENING_MESSAGE\033[0m"

### Get scripts parent directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# declare array
SYMLINKS=()
SYMLINKS+=("$DIR/.bashrc $HOME/.bashrc")
SYMLINKS+=("$DIR/.inputrc $HOME/.inputrc")
SYMLINKS+=("$DIR/.bash_profile $HOME/.bash_profile")
SYMLINKS+=("$DIR/.zshrc $HOME/.zshrc")
SYMLINKS+=("$DIR/.bash_completion $HOME/.bash_completion")
SYMLINKS+=("$DIR/.alacritty.toml $HOME/.alacritty.toml")

# Check OS
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

if [ ${machine} = MinGw ]; then
  # assume we are running git bash
  echo "You are running Windows. You will want to install Powerline/Nerd Fonts if you haven't already"
  echo "See: https://docs.microsoft.com/en-us/windows/terminal/tutorials/powerline-setup"
  echo "Then use this font in your terminal: [DejaVu Sans Mono for Powerline]"
  # powershell ./setup-powerline-fonts-windows.ps1
fi

#printf '%s\n' "${SYMLINKS[@]}"
#
for i in "${SYMLINKS[@]}"; do
  #echo $i
  # split each command at the space to get config path
  IFS=' ' read -ra OUT <<< "$i"
  # ${OUT[1]} is path config file should be at
  #no config, create symlink to one
  if [ ! -f "${OUT[1]}" ] && [ ! -L "${OUT[1]}" ]; then
    echo "Creating $i"
    ln -s $i

  #config exists; save if doesn't point to correct target
  elif [ "$(readlink -- "${OUT[1]}")" != "${OUT[0]}" ]; then
    echo "MOVING ${OUT[1]} to ${OUT[1]}.saved"
    mv "${OUT[1]}" "${OUT[1]}.saved"
    ln -s $i
  fi
done

echo "Adding tecfu-terminal-loadkeys group for CAPS->ESC mapping in /dev/ttyX..."
sudo groupadd tecfu-terminal-loadkeys           
sudo chgrp tecfu-terminal-loadkeys /usr/bin/loadkeys
sudo chmod 4750 /usr/bin/loadkeys 
sudo gpasswd -a $USER tecfu-terminal-loadkeys     

printf "\n"

WARN_MESSAGE="WARN: YOU MUST RESTART YOUR TERMINAL TO SEE CHANGES"
echo -e "\033[0;33m$WARN_MESSAGE\033[0m"

CLOSING_MESSAGE="ENDING $PRODUCT CONFIGURATION INSTALL"
echo -e "\033[0;32m$CLOSING_MESSAGE\033[0m"
