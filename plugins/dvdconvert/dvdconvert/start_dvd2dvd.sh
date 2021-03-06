#!/bin/bash
[ -r /etc/default/vdr ] || exit
. /etc/default/vdr

GETVAL="sh $VDRSCRIPTDIR/dvdconvert/getadmval.sh"
SETVAL="sh $VDRSCRIPTDIR/dvdconvert/setadmval.sh"
DVD2DVD="$VDRSCRIPTDIR/dvdconvert/dvd2dvd.sh"
DVD2DVD_CFG="$VDRCONFDIR/plugins/dvd2dvd.conf"
LOG_FILE="$VDRVARDIR/dvdconvert/log/dvd2dvd.log"

ACTION=`$GETVAL ACTION1`
echo "ACTION="$ACTION > $DVD2DVD_CFG

LANGUAGE=`$GETVAL LANGUAGE1`
echo "LANGUAGE="$LANGUAGE >> $DVD2DVD_CFG

OSDINFO=`$GETVAL OSDINFO1`
echo "OSDINFO="$OSDINFO >> $DVD2DVD_CFG

TITLE=`$GETVAL TITLE1`
echo "TITLE="$TITLE >> $DVD2DVD_CFG

TITLENUM=`$GETVAL TITLENUM1`
echo "TITLENUM="$TITLENUM >> $DVD2DVD_CFG

ACTION_DEMUX=`$GETVAL ACTION_DEMUX1`
echo "ACTION_DEMUX="$ACTION_DEMUX >> $DVD2DVD_CFG

WITHOUT_X=`$GETVAL WITHOUT_X1`
echo "WITHOUT_X="$WITHOUT_X >> $DVD2DVD_CFG

A52DEC_GAIN=`$GETVAL A52DEC_GAIN1`
echo "A52DEC_GAIN="$A52DEC_GAIN >> $DVD2DVD_CFG

ACTION_ENCODE=`$GETVAL ACTION_ENCODE1`
echo "ACTION_ENCODE="$ACTION_ENCODE >> $DVD2DVD_CFG

ACTION_MPLEX=`$GETVAL ACTION_MPLEX1`
echo "ACTION_MPLEX="$ACTION_MPLEX >> $DVD2DVD_CFG

BURN=`$GETVAL BURN1`
echo "BURN="$BURN >> $DVD2DVD_CFG

RW_FORMAT=`$GETVAL RW_FORMAT1`
echo "RW_FORMAT="$RW_FORMAT >> $DVD2DVD_CFG

REMOVE_ISO=`$GETVAL REMOVE_ISO1`
echo "REMOVE_ISO="$REMOVE_ISO >> $DVD2DVD_CFG

REMOVE=`$GETVAL REMOVE1`
echo "REMOVE="$REMOVE >> $DVD2DVD_CFG

CLEAN=`$GETVAL CLEAN1`
echo "CLEAN="$CLEAN >> $DVD2DVD_CFG

VERBOSE=`$GETVAL VERBOSE1`
echo "VERBOSE="$VERBOSE >> $DVD2DVD_CFG

sh $DVD2DVD >> $LOG_FILE 2>&1&

exit 0


