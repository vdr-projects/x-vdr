#!/bin/sh
[ -r /etc/default/vdr ] || exit
. /etc/default/vdr
CFG_FILE="$VDRCONFDIR/plugins/dvdconvert.conf"

VAL=$2
NAME=$1

mv -f $CFG_FILE $CFG_FILE.org

NLINE=`cat $CFG_FILE.org | grep ":$NAME:"`

TYPE=`echo $NLINE | cut -f 4 -d ":"`
OLDVAL=`echo $NLINE | cut -f 3 -d ":"`
if [ "$TYPE" = "L" ] ; then
   ALL_VAL=`echo $NLINE | cut -f 6 -d ":" | sed 's/,/ /g'`
   IDX=0
   for i in $ALL_VAL ; do
      if [ "${i}" = "$VAL" ] ; then
	 VAL=$IDX
      fi
      IDX=$(($IDX+1))
   done
fi

cat $CFG_FILE.org | sed 's/:'$NAME':'$OLDVAL':/:'$NAME':'$VAL':/' > $CFG_FILE
