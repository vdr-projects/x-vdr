#!/bin/sh
VDR_CONF="/etc/default/vdr"
source $VDR_CONF
ADMIN_CFG_FILE="$VDRCONFDIR/plugins/admin/admin.conf"

# read VARS from $ADMIN_CFG_FILE
ALL_VARS=$(grep "^/" $ADMIN_CFG_FILE | cut -f 2 -d ":")

for VAR in $ALL_VARS; do
  VAL=$(grep -m 1 "^$VAR=" $VDR_CONF | cut -f 2 -d '=')
  VAL=$(eval echo $VAL)
  case "$VAL" in
    on)
      $VDRCONFDIR/plugins/admin/setadmval.sh $VAR 1
    ;;
    off)
      $VDRCONFDIR/plugins/admin/setadmval.sh $VAR 0
    ;;
    *)
      $VDRCONFDIR/plugins/admin/setadmval.sh $VAR "$VAL"
    ;;
  esac
done



