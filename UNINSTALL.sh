#!/bin/bash

###
#   RUN THIS WITH /bin/bash NOT /bin/sh
#   /bin/sh MAPS TO INCOMPATIBLE TERM EMULATORS
#   IN SOME OS
#
#   ```
#    $ /bin/bash UNINSTALL.sh
#   ```
#
###

# declare array
SYMLINKS=()
SYMLINKS+=("$HOME/.bashrc")
SYMLINKS+=("$HOME/.inputrc")
SYMLINKS+=("$HOME/.profile")
SYMLINKS+=("$HOME/.alacritty.toml")
SYMLINKS+=("$HOME/.scripts")
SYMLINKS+=("$HOME/.zshrc")


echo "Removing symlinks:"
#printf '%s\n' "${SYMLINKS[@]}"
#
for i in "${SYMLINKS[@]}"; do
  #echo $i
  # split each command at the space to get config path
  IFS=' ' read -ra OUT <<< "$i"
  #delete config if backup exists
  if [ -f "${OUT[0]}.saved" ] || [ -L "${OUT[0]}.saved" ]; then
    echo "Restoring saved $i"
    rm $i
    mv ${i}.saved $i
  fi
done

echo "Removing tecfu-terminal-loadkeys group for CAPS->ESC mapping in /dev/ttyX..."
sudo groupdel tecfu-terminal-loadkeys

printf "\n"
echo DONE
