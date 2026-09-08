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

# Static configs that apps never write: symlink straight into this checkout.
SYMLINKS=()
SYMLINKS+=("$DIR/.inputrc $HOME/.inputrc")
SYMLINKS+=("$DIR/.alacritty.toml $HOME/.alacritty.toml")
SYMLINKS+=("$DIR/starship.toml $HOME/.config/starship.toml")

# Shell entry files that app installers mutate (nvm, cargo, fzf, oh-my-bash,
# bash-completion). These must NOT be symlinks into this checkout: apps append
# to the $HOME file, which dirties the git tree and blocks every
# `git pull --recurse-submodules`. Instead $HOME gets a small loader file that
# sources the tracked template.
LOADERS=()
LOADERS+=("$DIR/.bashrc $HOME/.bashrc")
LOADERS+=("$DIR/.bash_profile $HOME/.bash_profile")
LOADERS+=("$DIR/.profile $HOME/.profile")
LOADERS+=("$DIR/.zshrc $HOME/.zshrc")
LOADERS+=("$DIR/.bash_completion $HOME/.bash_completion")

install_loader() {
  local src="$1" dst="$2" name="${2##*/}"
  # Already a loader (app blocks may be appended below it): leave it alone.
  if [ -f "$dst" ] && [ ! -L "$dst" ] && grep -qF ".terminal/$name" "$dst" 2>/dev/null; then
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "MOVING: $dst to $dst.saved"
    mv "$dst" "$dst.saved"
  fi
  echo "LOADER: $dst sources \$HOME/.terminal/$name"
  cat > "$dst" <<EOF
# Managed by ~/.terminal INSTALL.sh (dotfiles). The tracked config is sourced
# from ~/.terminal; app installers (nvm, cargo, fzf, ...) append to THIS file.
[ -f "\$HOME/.terminal/$name" ] && . "\$HOME/.terminal/$name"
EOF
}

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

if [ ${machine} = Linux ] || [ ${machine} = Mac ]; then
  # Prompt: starship (https://starship.rs) — static binary, config in this
  # checkout is symlinked below to ~/.config/starship.toml.
  if command -v starship &> /dev/null; then
    echo "INFO: starship already installed: $(command -v starship)"
  else
    if ! command -v curl &> /dev/null; then
      sudo apt-get install -y curl
    fi
    echo "INFO: Installing starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
  fi

  # Install the bundled Nerd Font required by .alacritty.toml
  FONT_SRC="$DIR/../.vim/fonts/JetBrains Mono Regular Nerd Font Complete.ttf"
  if [ -f "$FONT_SRC" ]; then
    # fontconfig ships with Ubuntu desktop; install it if missing
    if ! command -v fc-cache &> /dev/null && command -v apt-get &> /dev/null; then
      echo "INFO: Installing fontconfig..."
      sudo apt-get install -y fontconfig
    fi
    if command -v fc-cache &> /dev/null; then
      mkdir -p "$HOME/.local/share/fonts"
      cp -u "$FONT_SRC" "$HOME/.local/share/fonts/"
      fc-cache -f "$HOME/.local/share/fonts" &> /dev/null
      echo "INFO: Installed JetBrainsMono Nerd Font to ~/.local/share/fonts"
    fi
  else
    echo "WARN: Bundled Nerd Font not found at $FONT_SRC"
    echo "WARN: Alacritty config expects 'JetBrainsMono Nerd Font'. Install it manually."
  fi
fi

mkdir -p "$HOME/.config"
for i in "${SYMLINKS[@]}"; do
  IFS=' ' read -ra OUT <<< "$i"
  # ${OUT[1]} is path config file should be at
  # no config, create symlink to one
  if [ ! -f "${OUT[1]}" ] && [ ! -L "${OUT[1]}" ]; then
    echo "SYMLINK: $i"
    ln -s $i

  # config exists; save if doesn't point to correct target
  elif [ "$(readlink -- "${OUT[1]}")" != "${OUT[0]}" ]; then
    echo "MOVING: ${OUT[1]} to ${OUT[1]}.saved"
    mv "${OUT[1]}" "${OUT[1]}.saved"
    echo "SYMLINK: $i"
    ln -s $i
  fi
done

if which Xorg &> /dev/null; then
    echo "INFO: X Window System is installed, skipping loadkeys group add for ESC remap"
else
    echo "INFO: X Window System is not installed."
    echo "INFO: Adding tecfu-terminal-loadkeys group for CAPS->ESC mapping in /dev/ttyX..."
    sudo groupadd tecfu-terminal-loadkeys
    sudo chgrp tecfu-terminal-loadkeys /usr/bin/loadkeys
    sudo chmod 4750 /usr/bin/loadkeys
    sudo gpasswd -a $USER tecfu-terminal-loadkeys
fi

# Loaders are written LAST: they always end up owning $HOME shell entry files.
for i in "${LOADERS[@]}"; do
  IFS=' ' read -ra OUT <<< "$i"
  install_loader "${OUT[0]}" "${OUT[1]}"
done

WARN_MESSAGE="WARN: YOU MUST RESTART YOUR TERMINAL TO SEE CHANGES"
echo -e "\033[0;33m$WARN_MESSAGE\033[0m"
