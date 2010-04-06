#!/bin/bash
source /etc/default/vdr

if [ "$1" = "-init" ]; then
   # write settings from /etc/default/vdr to admin.conf
   at -f $VDRCONFDIR/plugins/admin/setadm.sh now
elif [ "$1" = "-start" ]; then
   echo "Starting admin plugin"
elif [ "$1" = "-save" ]; then
   # write settings from admin.conf to /etc/default/vdr
   # this could only be by root
   sudo $VDRSCRIPTDIR/vdr2root admin
else
   echo "Illegal Parameter <$1>"
fi
