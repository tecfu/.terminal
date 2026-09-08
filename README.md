# Terminal Configuration Presets

## Scope

- Files
  - 256colors2.pl
    - Install 24 bit color support for virtual terminals
  - .alacritty.yml
    - Keymappings for alacritty
  - .bashrc
    - Prompt: starship (binary + `starship.toml`) — see "Prompt (starship)" below
  - custom.kmap
    - Remaps CAPS_LOCK to ESC in \*nix virtual terminal using `loadkeys`
  - .bash_completion.sh
    - Tmux autocompletion file
  - .inputrc
    - Custom key mappings
  - .profile
    - index for profile-\* files
  - profile-aliases-private.sh
    - Aliases that are specific to your machine or which you don't want public
  - profile-aliases-public.sh
    - Aliases that are useable on all your machines
  - profile-autocompletion.sh
    - General
      - Bash
    - Git
    - Terraform
    - Tmux
      - Bash: Uses https://github.com/imomaliev/tmux-bash-completion
  - profile-env.sh
    - Environment variables
  - profile-general.sh
    - General configuration
  - profile-vi-mode.sh
    - Puts terminal in vi mode key mappings
    - Adds some vim key mappings

## Installation

```
git clone https://github.com/tecfu/.terminal ~/.terminal
. ~/.terminal/INSTALL.sh
```

### Install Nerd Fonts

`INSTALL.sh` copies the bundled JetBrainsMono Nerd Font to `~/.local/share/fonts` and refreshes the font cache automatically on Linux and Mac.

Manual install (or if the bundled font is missing):

- Linux / Mac

  ```
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
  unzip JetBrainsMono.zip
  ```

  Then install `JetBrains Mono Regular Nerd Font Complete.ttf`

- Windows

  https://docs.microsoft.com/en-us/windows/terminal/tutorials/powerline-setup

  ```
  Install-Module posh-git -Scope CurrentUser
  Install-Module oh-my-posh -Scope CurrentUser -RequiredVersion 2.0.412
  Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
  ```

  Then use this font in your terminal DejaVu Sans Mono for Powerline

### OPTIONAL: Change keymap for virtual terminals

custom_keymap.kmap maps ESC to CAPS_LOCK

```bash
sudo loadkeys custom_keymap.kmap
echo "/usr/bin/loadkeys $HOME/custom_keymap.kmap" >> /etc/rc.local
```

See: https://superuser.com/questions/290115/how-to-change-console-keymap-in-linux

### OPTIONAL: Install 24 bit color support for virtual terminals

See:

https://github.com/tecfu/kmscon

### Checking your terminal for 256 colors

- Run the file ./256colors2.pl and check for tiled blocks that
  represent 256 colors in the output.

## Prompt (starship)

The prompt is [starship](https://starship.rs): a static binary plus one
declarative config, `starship.toml` (symlinked to `~/.config/starship.toml`
by INSTALL.sh). It renders the prompt and handles window-width truncation
itself. Nothing generates or rewrites shell startup files, so upgrades can't
clobber `~/.bashrc` the way oh-my-bash did. Without the binary you get
bash's default prompt.

Two lines:

```
venv git ~/path            ...right-aligned... clock battery user@host
❯
```

- `❯` turns red after a failed command.
- `user@host` shows only over SSH.
- Battery shows on machines with one; amber at 25%, red at 5%.
- Per-machine tweaks: set `STARSHIP_CONFIG` in `~/.bashrc.local`, or replace
  the `~/.config/starship.toml` symlink with a real file.

### Troubleshooting

- Search for a the source of an alias:

    ```
    ag 'alias vim' ~/.terminal/*
    ```
