#!/usr/bin/env tclsh

set database [lindex $argv 0]
set action   [lindex $argv 1]

if { $database == "" } {
  set action help
}

set files ""
set verbose 0

proc db_link {a b} {
  global files verbose
  dict set files $a link $b
  dict set files [file dirname $a] ignore 1
  if $verbose { puts [list copy $a $b] }
}
proc db_copy {a b} {
  global files verbose
  dict set files $a copy $b
  dict set files [file dirname $a] ignore 1
  if $verbose { puts [list link $a $b] }
}
proc db_noisy {a} {
  global files verbose
  foreach i $a {
    dict set files $i noisy 1
    if $verbose { puts [list noisy $i] }
  }
}
proc db_ignore {a} {
  global files verbose
  foreach i $a {
    dict set files $i ignore 1
    if $verbose { puts [list ignore $i] }
  }
}
proc read_database {database} {
  set i [interp create]
  interp alias $i link   {} db_link
  interp alias $i copy   {} db_copy
  interp alias $i noisy  {} db_noisy
  interp alias $i ignore {} db_ignore
  interp eval $i source $database
  return $i
}

proc clean_path {path} {
  set clean ""
  foreach item [file split $path] {
    if {$item == "."} {
      continue
    } elseif {$item == ".."} {
      if {[lindex $clean end] != ".." && [llength $clean]} {
	# remove last element
	set clean [lreplace $clean end end]
      } else {
	lappend clean ".."
      }
    } else {
      lappend clean $item
    }
    return [file join $clean]
  }
}

proc get_link_target {sourcefile target} {
  set sourcedir [file dirname $sourcefile]
  if { [file pathtype $target] == "relative" } {
    if {$sourcedir != "."} {
      set reverse ""
      set fail 0
      foreach item [file split $sourcedir] {
	if {$item == "."} {
	  continue
	} elseif {$item == ".."} {
	  set fail 1
	  break
	} else {
	  lappend reverse ".."
	}
      }
      if $fail {
	# Can't compute reverse path
	set sourcetarget [file normalize $target]
      } else {
	set sourcetarget [file join {*}$reverse $target]
      }
    } else {
      # no directory component in source
      set sourcetarget $target
    }
  }
  return $sourcetarget
}

switch -exact -- $action {
  link {
    if {[lindex $argv 2] != "-n"} { set do_things 1 } else { set do_things 0 }
    read_database $database
    set databasedir [file dirname $database]
    dict for {sourcefile v} $files {
      if [dict exists $v link] {
	set destfile [dict get $v link]
	set target   [file join $databasedir $destfile]
	set n_target [file normalize $target]
	if { ! [file exists $target] } {
	  if [file exists $sourcefile] {
	    puts "Move:     $sourcefile -> $target"
	    if $do_things {
	      file mkdir [file dirname $target]
	      file rename $sourcefile $target
	    }
	  } else {
	    continue
	  }
	}
	if { ! [catch {set srctarget [file link $sourcefile]}]} then {
	  set srctarget [file join [file dirname $sourcefile] $srctarget]
	  set n_srctarget [file normalize $srctarget]
	  if { $n_srctarget != $n_target} {
	    puts "Existing: $sourcefile -> $target"
	  }
	  # else the link is already ok
	} elseif [file exists $sourcefile] {
	  puts "Existing: $sourcefile"
	} else {
	  set sourcetarget [get_link_target $sourcefile $target]
	  puts "Create:   $sourcefile -> $sourcetarget"
	  if $do_things {
	    file mkdir [file dirname $sourcefile]
	    file link $sourcefile $sourcetarget
	  }
	}
      } elseif [dict exists $v copy] {
	set destfile [dict get $v copy]
	set target   [file join $databasedir $destfile]
	set n_target [file normalize $target]
	if { ! [file exists $sourcefile] } {
	  puts "Copy:     $target -> $sourcefile"
	  file copy $n_target $sourcefile
	}
      }
    }
  }
  clean {
    read_database $database
    set flag [lindex $argv 2]
    dict for {sourcefile v} $files {
      if [dict exists $v noisy] {
	if [file exists $sourcefile] {
	  puts $sourcefile
	  if {$flag != "-n"} {
	    file delete -force -- $sourcefile
	  }
	}
      }
    }
  }
  noisy {
    read_database $database
    set flag [lindex $argv 2]
    dict for {sourcefile v} $files {
      if [dict exists $v noisy] {
	if {$flag != "-a" || [file exists $sourcefile]} {
	  puts $sourcefile
	}
      }
    }
  }
  unknown {
    read_database $database
    set all_files [concat [glob -nocomplain *] [glob -type hidden -nocomplain *]]
    foreach item $all_files {
      if {$item == "." || $item == ".."} { continue }
      if {![dict exists $files $item]} {
	puts $item
      }
    }
  }
  run {
    if {[lindex $argv 2] == "-v"} {
      set verbose 1
    }
    read_database $database
  }
  default {
    puts "Usage: $argv0 database action ..."
    puts ""
    puts " actions:"
    puts ""
    puts "    help"
    puts "        This help"
    puts ""
    puts "    link \[-n\]"
    puts "        Create links from the current directory to the directory"
    puts "        of the database of the link files"
    puts "        -n  don't do anything"
    puts ""
    puts "    clean \[-n\]"
    puts "        Delete noisy files"
    puts "        -n  only list existing noisy files, like noisy"
    puts ""
    puts "    noisy \[-a\]"
    puts "        List existing noisy files"
    puts "        -a  list all noisy files, even those that don't exist"
    puts ""
    puts "    unknown"
    puts "        List unknown files in the current directory"
    puts ""
    puts "    run \[-v\]"
    puts "        Only run the database"
    puts "        -v  verbose mode"
    puts ""
    puts " database format:"
    puts ""
    puts "    The database is a tcl file with the following available commands:"
    puts ""
    puts "    link A B"
    puts "        make a link from file A (current dir) to B (database dir)"
    puts ""
    puts "    noisy F"
    puts "        declare the file F as noisy (current dir)"
    puts ""
    puts "    ignore F"
    puts "        ignore F in all actions"
    puts ""
  }
}

