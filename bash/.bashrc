# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
        *i*) ;;
        *) return;;
esac

# https://wiki.gentoo.org/wiki/Nushell#Caveats
# Use nushell in place of bash
# keep this line at the bottom of ~/.bashrc
[ -x /usr/bin/nu ] && SHELL=/usr/bin/nu exec nu
