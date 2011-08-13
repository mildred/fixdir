zshrc-zkbd(){

  autoload zkbd
  [[ -n $DISPLAY ]] && DISPLAY=X11
  zkbd_file=${ZDOTDIR:-$HOME}/.zkbd/$TERM-${DISPLAY:-$VENDOR-$OSTYPE}
  if [[ -f $zkbd_file ]]; then
    source $zkbd_file
  else
    echo "Missing key bindings: $zkbd_file"
    echo
    zkbd
    if [[ ! -f $zkbd_file ]]; then
      echo "***"
      echo "*** ERROR: Missing file '$zkbd_file'"
      echo "***"
    else
      source $zkbd_file
    fi
  fi

}


open-filemanager-cwd() { fm >/dev/null 2>&1 }
zle -N open-filemanager-cwd


#bindkey -v # vi mode
bindkey -e # emacs mode
# \e is the escape character shown as ^[ in the terminal
# use showkey -a or cat

# bindkey '^[[3~'     delete-char             # delete
# bindkey '^[[5~'     up-history              # page up
# bindkey '^[[6~'     down-history            # page down
# bindkey '^[[A'      up-line-or-history      # up
# bindkey '^[[B'      down-line-or-history    # down
bindkey '^f'        history-search-backward # ctrl-f
bindkey '^U'        history-search-forward  # ctrl-shift-f
bindkey '^x'        push-line-or-edit       # ctrl-x
bindkey '^u'        undo                    # ctrl-u



case ${TERMINAL_EMULATOR:-$TERM} in
rxvt-unicode)
    bindkey '^[[3^'     delete-word             # ctrl-delete
    bindkey '^[Od'      backward-word           # ctrl-left
    bindkey '^[Oc'      forward-word            # ctrl-right
    bindkey '^[[7~'     beginning-of-line       # begin
    bindkey '^[[8~'     end-of-line             # end
    ;;
xterm|roxterm|gnome-terminal)
    bindkey '^[[3;5~'   delete-word             # ctrl-delete
    bindkey '^[[1;5D'   backward-word           # ctrl-left
    bindkey '^[[1;5C'   forward-word            # ctrl-right
    bindkey '^[[H'      beginning-of-line       # begin
    bindkey '^[[F'      end-of-line             # end
    bindkey '^[OH'      beginning-of-line       # begin     (vte)
    bindkey '^[OF'      end-of-line             # end       (vte)
    ;;
linux)
    bindkey '^[[3~'     delete-word             # ctrl-delete
#    bindkey '^[[D'      backward-word           # ctrl-left
#    bindkey '^[[C'      forward-word            # ctrl-right
    bindkey '^[[1~'     beginning-of-line       # begin
    bindkey '^[[4~'     end-of-line             # end
    ;;
*)
    echo "Unknown terminal $TERM, some key bindings are disabled"
    ;;
esac

zshrc-zkbd

[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char
[[ -n "${key[F12]}"     ]]  && bindkey  "${key[F12]}"     open-filemanager-cwd

# Those are called widgets ^^^
# List of them in <http://chronos.cs.msu.su/zsh-man/zsh_19.html#SEC83>

