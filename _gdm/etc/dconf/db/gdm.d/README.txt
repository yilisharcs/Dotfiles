# Hello, future me.
# 
# Generate a dconf database for the `Debian-gdm` user from
# the `10-my-settings` file with `sudo dconf update`, then
# move it to the correct location with correct permissions:
# 
#     chown Debian-gdm:Debian-gdm /etc/dconf/db/gdm
#     mv /etc/dconf/db/gdm ~/Dotfiles/_gdm/var/lib/gdm3/.config/dconf/user
# 
# This is garbage, but I spent four hours trying to make it
# work by following the Arch wiki; didn't work. I'm all out
# of free time. Hacky way it is.
