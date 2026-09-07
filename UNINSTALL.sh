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

# Static configs installed as symlinks: restore the saved backup if present.
SYMLINKS=()
SYMLINKS+=("$HOME/.inputrc")
SYMLINKS+=("$HOME/.alacritty.toml")
SYMLINKS+=("$HOME/.scripts")

# Shell entry files installed as loaders: remove only ours (marker check);
# if a pre-dotfiles backup exists, restore it.
LOADERS=()
LOADERS+=("$HOME/.bashrc")
LOADERS+=("$HOME/.bash_profile")
LOADERS+=("$HOME/.profile")
LOADERS+=("$HOME/.zshrc")
LOADERS+=("$HOME/.bash_completion")

echo "Restoring symlinked configs:"
for i in "${SYMLINKS[@]}"; do
  #delete config if backup exists
  if [ -f "${i}.saved" ] || [ -L "${i}.saved" ]; then
    echo "Restoring saved $i"
    rm -f "$i"
    mv "${i}.saved" "$i"
  fi
done

echo "Removing loader files:"
for i in "${LOADERS[@]}"; do
  # only ours — real user configs and app-appended blocks are left alone
  if [ -f "$i" ] && [ ! -L "$i" ] && grep -qF ".terminal/" "$i" 2>/dev/null; then
    if [ -e "${i}.saved" ]; then
      echo "Restoring saved $i"
      rm -f "$i"
      mv "${i}.saved" "$i"
    else
      echo "Removing $i"
      rm -f "$i"
    fi
  fi
done

echo "Removing tecfu-terminal-loadkeys group for CAPS->ESC mapping in /dev/ttyX..."
sudo groupdel tecfu-terminal-loadkeys

printf "\n"
echo DONE
