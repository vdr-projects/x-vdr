#!/bin/sh
[ -r /etc/default/vdr ] || exit
. /etc/default/vdr
CFG_FILE="$VDRCONFDIR/plugins/dvdconvert.conf"

VAL=`cat $CFG_FILE | grep ":$1:" | cut -f 3 -d ":"`
TYPE=`cat $CFG_FILE | grep ":$1:" | cut -f 4 -d ":"`
if [ "$TYPE" = "L" ] ; then
   ALL_VAL=`cat $CFG_FILE | grep ":$1:" | cut -f 6 -d ":" | grep ","`
   VAL=$(($VAL+1))
   SET_VAL=`echo $ALL_VAL | cut -f $VAL -d ","`
else
   SET_VAL=$VAL
fi

echo `echo $SET_VAL | sed 's/^ //'g`
