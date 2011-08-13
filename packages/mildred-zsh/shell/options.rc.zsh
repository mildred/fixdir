# number of lines kept in history
export HISTSIZE=1000000
# number of lines saved in the history after logout
export SAVEHIST=1000000
# location of history
export HISTFILE=~/.zhistory
# append command to history file once executed
setopt INC_APPEND_HISTORY	# append to history file each time a line is executed
#setopt APPEND_HISTORY		# append at shell exit only
setopt EXTENDED_HISTORY		# add date and duration of commands in the history
setopt HIST_IGNORE_DUPS		# don't store duplicate lines (consecutive)
setopt HIST_EXPIRE_DUPS_FIRST	# remove all duplicates when history is near full
setopt NO_BANG_HIST		# no history completion
setopt NO_HIST_BEEP		# no beep

