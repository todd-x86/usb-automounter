# USB Automounter
The jankiest auto-mounter for USB devices.

This single Bash script acts as a long-running daemon and scans /var/log/messages for USB storage attach/detach messages.  Upon each attach message, it subsequently calls mount and mounts as read-writeable under /media.  umount is called for detach messages but cross-references mounts under /media with device names in /dev.

I don't endorse this as a quality product, just sharing in case anyone gets stuck and needs a quick (but hacky) solution.
