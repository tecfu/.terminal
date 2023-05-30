# Terminal Configuration Presets

## What this configuration does:

- Puts terminal in vi mode
- Adds some vim key mappings

## What this configuration doesn't do:

- Add the C-k keybinding to reset the terminal in .inputrc or .profile. 
- Instead we use the custom keybinding option from [Alacritty](https://github.com/alacritty/alacritty) to do that.

### Installation

```
$ git clone https://github.com/tecfu/.terminal ~/.terminal
$ . ~/.terminal/INSTALL.sh
```

### OPTIONAL: Install Powerline Fonts

- Windows

  https://docs.microsoft.com/en-us/windows/terminal/tutorials/powerline-setup

  ```
  Install-Module posh-git -Scope CurrentUser
  Install-Module oh-my-posh -Scope CurrentUser -RequiredVersion 2.0.412
  Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
  ```

  Then use this font in your terminal DejaVu Sans Mono for Powerline
  
- Ubuntu

  ```
  sudo apt-get install fonts-powerline
  ```

  > For Alacritty font-powerline install won't work. Do:

  ```
  wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
  unzip JetBrainsMono.zip
  ```
  Then install `JetBrains Mono Medium Nerd Font Complete.ttf`


### OPTIONAL: Change keymap for virtual terminals

custom_keymap.kmap maps ESC to CAPS_LOCK

```
$ sudo loadkeys custom_keymap.kmap
$ echo "/usr/bin/loadkeys $HOME/custom_keymap.kmap" >> /etc/rc.local
```

See: https://superuser.com/questions/290115/how-to-change-console-keymap-in-linux

### OPTIONAL: Install 24 bit color support for virtual terminals

See:

https://github.com/tecfu/kmscon


### Checking your terminal for 256 colors:

- Run the file ./256colors2.pl and check for tiled blocks that
represent 256 colors in the output.
