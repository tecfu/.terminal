# Loadkeys requires sudo to run.
# To allow this, first do:
# ```
# $ sudo groupadd loadkeys             # you can use any group name 
# $ sudo chgrp loadkeys /usr/bin/loadkeys
# $ sudo chmod 4750 /usr/bin/loadkeys  # setuid, group- and user-only read and execution
# $ sudo gpasswd -a user loadkeys      # add user to the group
# ```
#
# See also: https://unix.stackexchange.com/a/85375/146921

if [[ `tty` =~ ^/dev/tty[0-9]+ ]] 
then
  echo ".terminal config: Loading custom keymap at ${BASH_SOURCE}";
  loadkeys ~/.terminal/custom.kmap;
fi
