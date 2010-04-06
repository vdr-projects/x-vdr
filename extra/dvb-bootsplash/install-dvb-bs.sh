#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 28.01.2007

# install-dvb-bs.sh

[ -r /etc/default/vdr ] || exit 1
. /etc/default/vdr

[ -f ./dvb-bootsplash ] || exit 2

if [ ! -f ./VDRboot.mpeg ]; then
  if [ ! -f ./startup.mpeg ]; then
    wget --tries=2 http://vdrportal.magdlos.com/downloads/startup.mpeg
    [ -f ./startup.mpeg ] || exit 3
  fi
  cp ./startup.mpeg ./VDRboot.mpeg
fi

[ -f ./VDRboot.mpeg ] || exit 4
cp -f ./VDRboot.mpeg $DIVXDIR

cp -f ./dvb-bootsplash /etc/init.d
chmod 0755 /etc/init.d/dvb-bootsplash
cd /etc/rcS.d
ln -s ../init.d/dvb-bootsplash S05dvb-bootsplash


