# Terminal Configuration Presets

## Scope

- Files
  - 256colors2.pl
    - Install 24 bit color support for virtual terminals
  - .alacritty.yml
    - Keymappings for alacritty
  - .bashrc
    - Prompt themes: `plain` (default), `powerline-multiline`, `powerline-multiline-host` — see "Prompt themes" below
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

## Prompt themes

`.bashrc` ships two prompt themes, selected with `PROMPT_THEME`. Put it in
`~/.bashrc.local` (machine-specific, sourced at the end of `.bashrc`), e.g.:

```bash
PROMPT_THEME=powerline-multiline
```

### `plain` (default)

The builder at the top of `.bashrc` (`__ps1_build`). Single line:

```
user@host ~/path (git-branch *) [exit-status] [battery]
$
```

Built on git's own `git-sh-prompt` — no framework, no special font required.

### `powerline-multiline`

A self-contained re-creation of the oh-my-bash theme of the same name
(`__ps1_build_pml`). Two lines:

```
[venv][git][cwd]                ...right-aligned... [clock][battery][user]
[failed exit status] ❯
```

- Git block color reflects repo state: clean 25, staged 30, unstaged 92,
  dirty (both) 88; branch name or short SHA on detached HEAD.
- Battery shows always on machines with a battery, with a lightning bolt
  prefix while on AC power; colors turn amber at 25% and red at 5%.
- Shows `user@host` only over SSH.
- Responsive to the terminal width: on a narrow window right-side segments are
  shed in order (clock, then battery, then user) and a long cwd keeps only its
  tail (`…/structure/that/keeps/going/on`), so the two sides never overlap.
- Requires a powerline/nerd font for the arrow separators (U+E0B0 / U+E0B2)
  — see "Install Nerd Fonts" above. Without one you get hollow boxes.
- `THEME_CLOCK_FORMAT` (a strftime string) changes the clock format;
  default `%H:%M:%S`.

### `powerline-multiline-host`

Same layout as `powerline-multiline`, with a darkreader-style color scheme
unique to each machine: a hash of the hostname picks a hue, the statusbar
becomes a medium-dark tint of that hue, and all text becomes a light,
desaturated version of the same hue — so text is always readable, whatever
the hash picks. Git and battery state colors move from block background to
light text colors (clean 117, staged 80, unstaged 141, dirty 203, battery
low 114, others unchanged).

- Needs a truecolor (24-bit) terminal; falls back to garbage colors on
  256-color-only terminals (check with `./256colors2.pl`).
- Colors are deterministic per hostname — same machine, same colors.
- Hash collisions between similarly named machines can land on close hues;
  saturation/lightness jitter (independent hash slices) keeps them apart.
  Same font requirement as `powerline-multiline`.

### Troubleshooting

- Search for a the source of an alias:

    ```
    ag 'alias vim' ~/.terminal/*
    ```
