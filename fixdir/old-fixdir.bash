#! /bin/bash

C_H1="\033[1;37m"
C_H2="\033[1;36m"

C_CLEAR="\033[1;0m"

ask(){
    echo -ne "$C_H2$1$C_CLEAR "
    read -n 1 ask
    ask="`echo "$ask" | tr 'A-Z' 'a-z'`"
    [ "`echo`" != "$ask" ] && echo
}
ask-default-yes(){
    ask "$1 (Y/n)"
    [ "n" != "$ask" ] && return 0 || return 1
}
ask-default-no(){
    ask "$1 (y/N)"
    [ "y" != "$ask" ] && return 1 || return 0
}

if [ -n "$1" ]; then
    localdir="$1"
else
    localdir="`dirname "$0"`"
fi

if [ -n "$2" ]; then
    cd "$2"
fi

if [ -n "$3" ]; then
    database="$3"
else
    database="$localdir/database.sh"
fi

echo "This script will maintain a set of  symbolic links in DESTDIR pointing to"
echo "files located in TARGETDIR according to a database file DATABASE. These 3"
echo "values can be detected from the command line according to the format:"
echo "    `basename "$0"` TARGETDIR [DESTDIR [DATABASE]]"
echo "    cd DESTDIR; TARGETDIR/`basename "$0"`"
echo "The default location for the database is DESTDIR/database.sh"
echo "The detected values are:"
echo "    TARGETDIR  `pwd`"
echo "    DESTDIR    $localdir"
echo "    DATABASE   $database"
echo "Note that this script currently works only if DESTDIR is inside TARGETDIR"
echo "and it will create relative symbolics links with the DESTDIR path."
echo "The format of the database is a shell  script. Each entry begiin with the"
echo "keyork  \`line'.  The first parameter  is the name  of the target  file in"
echo "DESTDIR and the second parameter is the name of the link in TARHETDIR."
echo

if [ -z "$2" ] && [ "a`pwd`" != "a$HOME" ]; then
    echo "WARNINING: DESTDIR is not your homedir, are you shure ?"
    ask-default-no "Continue ?" || exit 0
else
    ask-default-yes "Continue ?" || exit 0
fi

reversepath(){
    if echo "$1" | grep '\.\.' >/dev/null; then
        echo "Error, malformed entry in the database." >&2
        echo "The entry contains '..'. This is not accepted." >&2
        echo "Entry: $1" >&2
        exit 1
    fi
    [ "a." = "a$1" ] && { echo '.'; return; }
    echo "$1" \
        | sed 's|^\.$||'        \
        | sed 's|^\(\./\)*||'   \
        | sed 's|/\./|/|g'      \
        | sed 's|\(/\.\)*$||'   \
        | sed 's|[^/]*|..|g'    \
        | sed 's|^$|.|g'
}

log(){
    echo "$@"
    "$@"
    return "$?"
}

line(){
    local cfgname="$1"
    local homename="$2"
    local dir="`dirname "$homename"`"
    local rdir="`reversepath "$dir"`"
    if [ -e "$homename" ]; then
        # target already exists
        if [ -L "$homename" ]; then
            local target="$(
                stat -c %N "$homename" | \
                sed -r "s/\`.*' -> \`(.*)'/\1/"
                )"
            if [ a"$rdir/$localdir/$cfgname" = a"$target" ]; then
                # target is pointing to source, pass
                return 0
            else
                true
                echo "$rdir/$localdir/$cfgname" != "$target"
            fi
        fi
        # target is not pointing to source
        echo
        echo -e "current file name: $C_H1$homename$C_CLEAR (already exists)"
        if [ -L "$homename" ]; then
            echo -n "current file link: "
            stat -c %N "$homename"
        else
            stat -c "current file type: %F  size: %s" "$homename"
        fi
        if [ ! -e "$localdir/$cfgname" ]; then
            echo "does not exists:   $localdir/$cfgname"
        fi
        if [ -e "$localdir/$cfgname" ]; then
            # source exists
            echo "replace with link: \`$homename' -> \`$rdir/$localdir/$cfgname'"
            ask "Override/Import/Pass ? (o/i/P)"
            if [ o = "$ask" ]; then
                echo "Override"
                ask "Backup ? (Y/n)"
                if [ n = "$ask" ]; then
                    log rm -rf "$homename"
                else
                    echo -n "backup for $homename [$homename.backup]: "
                    read backup
                    if [ -z "$backup" ]; then
                        backup="$homename.backup"
                    fi
                    log mv "$homename" "$backup"
                fi
            elif [ i = "$ask" ]; then
                echo "Import"
                ask "Backup ? (Y/n)"
                if [ n = "$ask" ]; then
                    log rm -rf "$localdir/$cfgname"
                else
                    echo -n "backup for $localdir/$cfgname [$localdir/$cfgname.backup]: "
                    read backup
                    if [ -z "$backup" ]; then
                        backup="$localdir/$cfgname.backup"
                    fi
                    log mv "$homename" "$backup"
                fi
            else
                echo "Pass"
                return 0
            fi
        else
            # source do not exists
            echo "move and link:     \`$homename' -> \`$rdir/$localdir/$cfgname'"
            ask "Import/Pass ? (i/P)"
            if [ i = "$ask" ]; then
                echo "Import"
                log mkdir -p "`dirname "$localdir/$cfgname"`"
                log mv "$homename" "$localdir/$cfgname"
            else
                echo "Pass"
                return 0
            fi
        fi
    else
        # target do not exists
        if [ -e "$localdir/$cfgname" ]; then
            # link source to target
            echo
            echo "create link: \`$homename' -> \`$rdir/$localdir/$cfgname'"
        else
            # source do not exists either, ignore
            return 0
        fi
    fi
    local cwd="`pwd`"
    if [ ! -d "$dir/." ]; then
        log mkdir -p "$dir"
    fi
    #echo dir $dir rdir $rdir
    ln -s "$rdir/$localdir/$cfgname" "$homename"
    cd "$cwd"
    return 0
}

if [ ! -f "$database" ]; then
    echo "ERROR: The database database.sh is missing: $database" >&2
    exit 1
fi

source "$database"

exit 0

# encoding: utf-8
# kate: encoding utf-8; space-indent on; indent-width 4;
