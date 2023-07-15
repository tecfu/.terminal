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
### Get scripts parent directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# declare array
SYMLINKS=()
SYMLINKS+=("$DIR/.bashrc $HOME/.bashrc")
SYMLINKS+=("$DIR/.inputrc $HOME/.inputrc")
SYMLINKS+=("$DIR/.profile $HOME/.profile")
SYMLINKS+=("$DIR/.zshrc $HOME/.zshrc")
SYMLINKS+=("$DIR/.alacritty.yml $HOME/.alacritty.yml")
SYMLINKS+=("$DIR/.scripts $HOME/.scripts")

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
  echo "You're running Windows, so you'll want to install Powerline/Nerd Fonts if you haven't already"
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

printf "\n"
echo DONE
