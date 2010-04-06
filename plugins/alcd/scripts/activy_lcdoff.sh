#!/bin/sh
# Activy set Display text
#/bin/stty 38400 < /dev/ttyS0

#set -x

# modified for x-vdr (debian)
source  /etc/default/vdr

if [ "$alcd" = "on" ] ; then
   WAKEUP_FILE=${VIDEODIR}/~wakeup
   if [ -s $WAKEUP_FILE ] ; then
      NT=$(cat $WAKEUP_FILE | cut -f 1 -d ";")
      WT="$(date -d "1970-01-01 UTC $NT seconds" '+%d.%m.%Y - %R')"
      CH=$(cat $WAKEUP_FILE | cut -f 2 -d ";")
      PR=$(cat $WAKEUP_FILE | cut -f 3- -d ";" | cut -b 1-20)
      echo "$WT"
      echo "$CH-$PR"
      svdrpsend.pl PLUG alcd LOCK
      svdrpsend.pl PLUG alcd PWRLED BLINK
      svdrpsend.pl PLUG alcd SHOW "$WT|$PR"
      svdrpsend.pl PLUG alcd STAY "ON"
      sleep 3
   fi
fi


