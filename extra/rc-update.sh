#!/bin/sh

# vdr-installer fuer kanotix 
# von Marc Wernecke - 14.02.2006
# kanotix gibt es bei http://www.kanotix.com
#

if [ $# -eq 0 ] ; then 
echo "this script needs a command..." 
echo "possible commands are..."
echo "remove"
echo "defaults"
exit 
fi

unfreeze-rc.d 

case $1 in
  install )
	if [ -f /etc/init.d/samba ] ; then update-rc.d samba defaults 50 ; fi
  ;;

  remove )
	/etc/init.d/cupsys stop
	update-rc.d -f cupsys remove
	/etc/init.d/courier-authdaemon stop
	update-rc.d -f courier-authdaemon remove
	/etc/init.d/courier-mta stop
	update-rc.d -f courier-mta remove
	/etc/init.d/ppp stop
	update-rc.d -f ppp remove
  ;;
  defaults )
	if [ -f /etc/init.d/cupsys ] ; then update-rc.d cupsys defaults 20 ; fi
	if [ -f /etc/init.d/courier-authdaemon ] ; then update-rc.d courier-authdaemon defaults 20 ; fi
	if [ -f /etc/init.d/courier-mta ] ; then update-rc.d courier-mta defaults 20 ; fi
	if [ -f /etc/init.d/ppp ] ; then update-rc.d ppp defaults 14 ; fi
  ;;
  * ) 
	echo "\"$1\" - command not found"
	echo "possible commands are..."
	echo "remove"
	echo "defaults"
  ;;
esac

freeze-rc.d 

exit 0
