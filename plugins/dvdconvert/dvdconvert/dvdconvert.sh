#!/bin/sh
[ -r /etc/default/vdr ] || exit
. /etc/default/vdr
CFG_FILE="$VDRCONFDIR/plugins/dvdconvert.conf"
CFG_SAVE="$VDRCONFDIR/plugins/dvdconvert.conf.save"

TODO_FILE="/tmp/~dvdconvert.sh"
LOG_FILE="$VDRVARDIR/dvdconvert/log/dvdconvert.log"
rm -rf $TODO_FILE > /dev/null 2>&1
echo "#!/bin/sh" > $TODO_FILE
if [ -s $CFG_SAVE ] ; then
   ALL_SCRIPTS=`diff  $CFG_FILE $CFG_SAVE | grep "^< /" | cut -b 3- | cut -d ":" -f 1`
else
   ALL_SCRIPTS=`cat $CFG_FILE | grep "^/" | cut -d ":" -f 1`
fi
LAST_SCRIPT=""
for i in $ALL_SCRIPTS ; do
   if [ "${i}" != "$LAST_SCRIPT" ] ; then
      if [ -f ${i} ] ; then
         echo "sh ${i} >> $LOG_FILE 2>&1" >> $TODO_FILE
      else
         echo "<${i}> not found" >> $LOG_FILE
         echo "<${i}> not found"
      fi
   fi
   LAST_SCRIPT=${i}
done
#echo 'echo "Fertig"' >> $TODO_FILE
cp -f $CFG_FILE $CFG_SAVE
chmod +x $TODO_FILE
sh $TODO_FILE
