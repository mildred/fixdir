What is it?
===========

This is my homedir package manager. Written first in shell then translated in
tcl. Originally, this was just to maintain a set of symbolic links from my home
directory to a directory where all important comfig files were stored. Then I
decided to make it a package manager.

How to install it?
==================

    git clone git://github.com/mildred/fixdir.git fixdir
    fixdir_dir="$(pwd)/fixdir"
    cd
    "$fixdir_dir/fixdir" install "$fixdir_dir/hpkg.tcl"

`fixdir` is installed in `~/.local/bin`. Make sure it is in your `$PATH`.

How does it work
================

You must always be in your homedir. The target directory for `fixdir` is
always the current directory unless you specify it on the command line.

Invoke one action with a database file. The database file is a tcl script that
contain all files and directories that should be linked.

What else can it do?
====================

`fixdir unknown` list all files not manages by fixdir in the current directory

`fixdir clean` remove files declared as noisy

TODO
====

* implement uninstall
* fix -t option

