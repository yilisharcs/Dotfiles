# Firejail profile for fightcade
# Description: Online retro gaming platform with Wine-based emulators
# This file is overwritten after every install/update
# Persistent local customizations
include fightcade.local
# Persistent global definitions
include globals.local

# Wine cache and prefix
noblacklist ${HOME}/.cache/wine
noblacklist ${HOME}/.cache/winetricks
noblacklist ${HOME}/.wine
noblacklist /tmp/.wine-*

# Fightcade data directory and symlink farm
noblacklist ${HOME}/Games

# Allow exec from home (Wine needs this)
ignore noexec ${HOME}

include disable-common.inc
include disable-devel.inc
include disable-interpreters.inc
include disable-programs.inc

# Wine prefix
mkdir ${HOME}/.wine

# Fightcade directories
mkdir ${HOME}/Games/Fightcade
mkdir ${HOME}/Games/.plugin/Fightcade
mkdir ${HOME}/.config/Fightcade

# Wine prefix (uses default ~/.wine, no WINEPREFIX set)
whitelist ${HOME}/.wine

# Fightcade data (incl. symlink farm at .plugin/Fightcade)
whitelist ${HOME}/Games/.plugin/Fightcade
whitelist ${HOME}/Games/Fightcade
whitelist ${HOME}/.config/Fightcade
include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-var-common.inc

keep-dev-ntsync

caps.drop all
ipc-namespace
netfilter
nodvd
nogroups
nonewprivs
noroot
notv
novideo
protocol unix,inet,inet6,netlink
seccomp !chroot,!clone3,!modify_ldt,!mount,!name_to_handle_at,!pivot_root,!process_vm_readv,!ptrace,!umount2

dbus-user filter
dbus-user.talk org.freedesktop.Notifications
dbus-system none

private-tmp
