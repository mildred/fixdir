autoload colors
colors

local reset="$terminfo[sgr0]"
local bold="$terminfo[bold]"
local red="$fg[red]"
local green="$fg[green]"
local blue="$fg[blue]"

local esc="$(echo '\e')"
local reset="${esc}[0m"
local bold=""
local red="${esc}[31m"
local green="${esc}[32m"
local blue="${esc}[0;34m"

local color_isok="%(?.%{$green%}.%{$red%})"
local retcode="%(?..%{$fg[yellow]%}(%{$red%}%B%?%b%{$fg[yellow]%}%) )"
# %(!.#.$) to have '$' or '#' sign like bash / %# to have either '%' or '#'
local id="$color_isok%n@%M%{$reset%}"
local loc="%{$blue%}%2~%{$reset%}"
local hash="%(!.#.$)"

export PS1="$id:$loc$hash "
export RPS1="$retcode%{$fg[yellow]%}%~%{$reset%}"

case $TERM in
    xterm*)
        precmd () {print -Pn "\e]0;%n@%m: %2~\a"}
        ;;
esac
