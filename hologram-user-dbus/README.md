# hologram-user-dbus

This hologram contains some boilerplate for starting a DBus session bus in a
systemd user session (this is inexplicably not included in the systemd
package out of the box).

With this hologram installed, you can `sudo` into any user session, say

    export XDG_RUNTIME_DIR=/run/user/$(id -u)

and you're able to use the DBus session bus, so e.g. `systemctl --user` will
work just fine.

## Source

All of this is more or less taken verbatim from
[the Arch Linux wiki](https://wiki.archlinux.org/index.php?title=Systemd/User&oldid=388746#D-Bus)
(this permalink references the specific version that was used). Therefore, this
hologram is licensed under the [GNU FDL 1.3 (or later)](http://www.gnu.org/copyleft/fdl.html) instead.
