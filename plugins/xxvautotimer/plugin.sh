#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 04.12.2006
#
# vdr-xxvautotimer

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://vdrtools.de/download/vdr-xxvautotimer-0.1.2.tgz"
VERSION="xxvautotimer-0.1.2"
LINK="xxvautotimer"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  log "cleaning $LINK"
}

# plugin installieren
function install_plugin() {
  download_plugin
  extract_plugin
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -f $LINK
  ln -vfs $VERSION $LINK
  patch_plugin

  ## plugin specials - start ##
  # auf libmysqlclient prüfen
  if [ -f "/usr/sbin/mysql_config" ]; then
    log "libmyasqlclient gefunden"
  else
    log "libmysqlclient nicht gefunden"
    apt_install libmysqlclient15-dev 
  fi
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/Scripte/epg2xxvautotimer.pl $VDRSCRIPTDIR
  chmod 0744 $VDRSCRIPTDIR/epg2xxvautotimer.pl
  chown $VDRUSER.$VDRGROUP $VDRSCRIPTDIR/epg2xxvautotimer.pl
  ## plugin specials - ende ##
}

# plugin commands
if [ $# \> 0 ]; then
  cmd=$1
  cmd_plugin
else
  install_plugin
  log "install-plugin fuer $VERSION ist fertig"
fi

exit 0
