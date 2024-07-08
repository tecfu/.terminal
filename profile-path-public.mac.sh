##################################
#
# asdf
# https://github.com/asdf-vm/asdf
#
#################################

. "/opt/homebrew/opt/asdf/libexec/asdf.sh"
. "/opt/homebrew/opt/asdf/etc/bash_completion.d/asdf.bash"

conditional_asdf() {
  if [ ! -f "$PWD/.tool-versions" ]; then
    export PATH=`echo $PATH | sed -E 's/(.*)\.asdf([^:]*)://'`
  else
    export PATH="${HOME}/.asdf/shims:${HOME}/.asdf/bin:${PATH}"
  fi
}

PROMPT_COMMAND="conditional_asdf; $PROMPT_COMMAND"

##################################
#
# Postgres Tools
# https://stackoverflow.com/questions/44654216/correct-way-to-install-psql-without-full-postgres-on-macos
#
#################################

export PATH=$PATH:/opt/homebrew/opt/libpq/bin
