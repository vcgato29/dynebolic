#!/bin/sh --no-zle
#
# generic shutdown script for dyne:bolic
# this should be run at halt and reboot and whenever
# the computer goes down, it also ejects the CD when present
#
# GNU GPL 2001-2004 by jaromil @ dyne.org
#

FILE_ID="\$Id$"
source /lib/libdyne.sh

notice "closing dyne:bolic session"

# Kill all processes.
# INIT is supposed to handle this entirely now, but this didn't always
# work correctly without this second pass at killing off the processes.
# Since INIT already notified the user that processes were being killed,
# we'll avoid echoing this info this time around.
if [ "$1" != "fast" ]; then # shutdown did not already kill all processes
   /sbin/killall5 -15
   /bin/sleep 5
   /sbin/killall5 -9
fi

# This is to ensure all processes have completed on SMP machines:
echo " .  wait to sync processes"
wait

echo -n " .  "
/usr/sbin/autofs stop

act "release swap"
/usr/sbin/swapoff -a

act "unload all kernel modules"
/sbin/rmmod -a

act "umount all volumes"
/bin/umount -a

echo " .  sync harddrives" # this never hurts
/sbin/sync

if [ "$DYNE_SYS_MEDIA" == "cd" ]; then
    echo "[*] ejecting dyne:bolic cd"
    eject "$DYNE_SYS_DEV"
fi

# sleep 1 fixes problems with some hard drives that
# don't finish syncing before reboot or poweroff
/bin/sleep 1


