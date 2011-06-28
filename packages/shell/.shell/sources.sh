## -*- sh -*-

has_sources=0
if [ -n "${ZSH_VERSION:-}" ]; then
    autoload -U is-at-least
    if is-at-least 4.3.9; then
        has_sources=0
    fi
elif [ -n "${BASH_VERSION:-}" ]; then
    if [ "${BASH_VERSINFO[0]}" -ge 3 ]; then
        has_sources=0
    fi
fi

if [ $has_sources = 0 ]; then
    sources () {
      local directory="$1"
      local kind="$2"
      local shell="$(basename "$SHELL")"
      for f in "$directory/"*".$kind" "$directory/"*".$kind.$shell"; do
        if [ -r "$f" ]; then
          source "$f"
        fi
      done
    }
fi
unset has_sources



