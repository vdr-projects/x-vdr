#!/bin/sh
source /etc/default/vdr
ADMIN_CFG_FILE="$VDRCONFDIR/plugins/admin/admin.conf"

NAME=$1
VAL=$2
DO_RESET=$3

NLINE=$(grep -m 1 ":$NAME:" $ADMIN_CFG_FILE)

if [ "$NLINE" = "" ] ; then
   logger -s "AdmVar: <$NAME> not found"
   exit 1
fi

GROUP=$(echo $NLINE | cut -f 1 -d ":")
TYPE=$(echo $NLINE | cut -f 4 -d ":")
OLDVAL=$(echo $NLINE | cut -f 3 -d ":")
DEFVAL=$(echo $NLINE | cut -f 5 -d ":")
NEWVAL=""

case "$TYPE" in
   L)
      ALL_VAL=$(echo $NLINE | cut -f 6 -d ":")
      for IDX in $(seq 1 99) ; do
         VALC=$(echo "$ALL_VAL" | cut -f $IDX -d ",")
         if [ "$VALC" = "" ] ; then
            break
         fi   
         if [ "${VAL}" = "${VALC}" ] ; then
          	 NEWVAL=$(($IDX - 1))
          	 break
         fi
      done
      if [ "$NEWVAL" = "" ] ; then
         logger -s "Value <$VAL> is not valid for $NAME"
         if [ $OLDVAL -ge 0 ] && [ $OLDVAL -lt $IDX ] ; then
            NEWVAL=$(printf "%d" $OLDVAL)
         else   
            logger -s "Old Value <$OLDVAL> is not valid for $NAME"
            if [ $DEFVAL -ge 0 ] && [ $DEFVAL -lt $IDX ] ; then
               NEWVAL=$(printf "%d" $DEFVAL)
            else   
               logger -s "Def Value <$DEFVAL> is not valid for $NAME - setting to 0"
               NEWVAL=0
            fi
         fi     
         VAL=$(echo "$ALL_VAL" | cut -f $(($NEWVAL + 1)) -d ",")
      fi   
      ;;
   A)
      NEWVAL=$(echo "$VAL" | sed -e 's/:/;/g')
#      NEWVAL=$VAL
      ;;
   B)
      if [ "$VAL" = "0" ] || [ "$VAL" = "1" ] ; then
         NEWVAL=$VAL
      else    
         logger -s "Value <$VAL> is not valid for $NAME"
         if [ "$OLDVAL" = "0" ] || [ "$OLDVAL" = "1" ] ; then
            NEWVAL=$OLDVAL
         else    
            logger -s "Old value <$VAL> is not valid for $NAME"
            if [ "$DEFVAL" = "0" ] || [ "$DEFVAL" = "1" ] ; then
               NEWVAL=$VAL
            else    
               logger -s "Def value <$VAL> is not valid for $NAME - setting to 0"
               NEWVAL=0
            fi
         fi
      fi
      VAL=$NEWVAL
      ;;
   I)
      MINVAL=$(echo $NLINE | cut -f 6 -d ":" |cut -f 1 -d ",")
      MAXVAL=$(echo $NLINE | cut -f 6 -d ":" |cut -f 2 -d ",")
      if [ $VAL -ge $MINVAL ] && [ $VAL -le $MAXVAL ] ; then
         NEWVAL=$(printf "%d" $VAL)
      else   
         logger -s "Value <$VAL> is not valid for $NAME"
         if [ $OLDVAL -ge $MINVAL ] && [ $OLDVAL -le $MAXVAL ] ; then
            NEWVAL=$(printf "%d" $OLDVAL)
         else   
            logger -s "Old Value <$OLDVAL> is not valid for $NAME"
            if [ $DEFVAL -ge $MINVAL ] && [ $DEFVAL -le $MAXVAL ] ; then
               NEWVAL=$(printf "%d" $DEFVAL)
            else   
               logger -s "Def Value <$DEFVAL> is not valid for $NAME - setting to $MINVAL"
               NEWVAL=$(printf "%d" $MINVAL)
            fi
         fi      
      fi
      VAL=$NEWVAL
      ;;
   *)  
      logger -s "Illegal line in $ADMIN_CFG_FILE :"
      logger -s "$NLINE"
      exit 1
      ;;
esac

if [ "$NEWVAL" = "" ] ; then
#   logger -s "Value <$VAL> is not valid for $NAME"
#   exit 1
   NEWVAL=" "
fi

if [ "$NEWVAL" != "$OLDVAL" ] ; then
   logger -s "Changing $NAME to <$NEWVAL> from <$OLDVAL> in $ADMIN_CFG_FILE"
   if [ "$GROUP" = "/DIR" ] || [ "$GROUP" = "/ARG" ]; then
     sed -i $ADMIN_CFG_FILE -e "s?\:$NAME\:$OLDVAL\:?\:$NAME\:$NEWVAL\:?"
   else
     sed -i $ADMIN_CFG_FILE -e "s/\:$NAME\:$OLDVAL\:/\:$NAME\:$NEWVAL\:/"
   fi
#else 
#   echo "${NAME} is already set to ${NEWVAL} in $ADMIN_CFG_FILE"
fi


