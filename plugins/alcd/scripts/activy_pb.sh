#!/bin/sh
# Activy power button
/bin/stty 38400 < /dev/ttyS0
if [ "$1" = "0" ] ; then
   printf "\x94\x21" > /dev/ttyS0
   printf "\x94\x30" > /dev/ttyS0
else
   printf "\x94\x12" > /dev/ttyS0
   printf "\x94\x03" > /dev/ttyS0
fi

