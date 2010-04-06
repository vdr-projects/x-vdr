#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 25.04.2008

RemoteConf="/var/lib/vdr/remote.conf"
VdrConf="/etc/default/vdr"
XvdrConf="/usr/local/src/x-vdr/setup.conf"

if [ -r "$VdrConf" -a -w "$VdrConf" ]; then
  . $VdrConf
  [ -f "$VDRCONFDIR/remote.conf" ] && RemoteConf="$VDRCONFDIR/remote.conf"
fi

[ -w "$RemoteConf" ] || exit 1

RemoteEvent=`grep -m1 "remote-event" $RemoteConf | cut -d "." -f1`
[ -n "$RemoteEvent" ] || exit 2

DeviceNr=`dmesg | grep -m1 "DVB on-card IR receiver" | tr "/" "\n" | grep input | grep [0-9] | cut -c6`
[ -n "$DeviceNr" ] || exit 3

if [ "$RemoteEvent" != "remote-event${DeviceNr}" ]; then
  sed -i $RemoteConf -e s/$RemoteEvent/remote-event${DeviceNr}/g
  echo "Changing Remote-Device in $RemoteConf from $RemoteEvent to remote-event${DeviceNr}"
else
  echo "Remote-Device in $RemoteConf is $RemoteEvent"
fi

if [ -w "$VdrConf" ]; then
  if [ -n "$remote_event" ]; then
    DeviceNrOld=`echo "$remote_event" | tr "/" "\n" | grep [0-9] | cut -c6`
    if [ "$DeviceNrOld" != "$DeviceNr" ]; then
      sed -i $VdrConf -e s?remote_event=\"/dev/input/event${DeviceNrOld}\"?remote_event=\"/dev/input/event${DeviceNr}\"?g
      echo "Changing Remote-Device in $VdrConf from $remote_event to /dev/input/event${DeviceNr}"
    fi
  fi
fi

if [ -r "$XvdrConf" -a -w "$XvdrConf" ]; then
  . $XvdrConf
  if [ -n "$remote_event" ]; then
    DeviceNrOld=`echo "$remote_event" | tr "/" "\n" | grep [0-9] | cut -c6`
    if [ "$DeviceNrOld" != "$DeviceNr" ]; then
      sed -i $XvdrConf -e s?remote_event=\"/dev/input/event${DeviceNrOld}\"?remote_event=\"/dev/input/event${DeviceNr}\"?g
      echo "Changing Remote-Device in $XvdrConf from $remote_event to /dev/input/event${DeviceNr}"
    fi
  fi
fi

exit 0
