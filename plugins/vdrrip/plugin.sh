#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 10.03.2009
#
# vdr-vdrrip

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/vdr-vdrrip/vdr-vdrrip-0.3.0-patched.tgz"
VERSION="vdrrip-0.3.0-patched"
LINK="vdrrip"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRSCRIPTDIR/queuehandler.sh
  rm -f $VDRSCRIPTDIR/queuehandler.sh.conf
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
  patch_p1_plugin

  ## plugin specials - start ##
  if [ -f $DIR/queuehandler.sh ]; then
    cp -f $DIR/queuehandler.sh $VDRSCRIPTDIR
  else
    cp -f $SOURCEDIR/VDR/PLUGINS/src/vdrrip/scripts/queuehandler.sh $VDRSCRIPTDIR
  fi
  if [ -f $DIR/queuehandler.sh.conf ]; then
    cp -f $DIR/queuehandler.sh.conf $VDRSCRIPTDIR
  else
    cp -f $SOURCEDIR/VDR/PLUGINS/src/vdrrip/scripts/queuehandler.sh.conf $VDRSCRIPTDIR
  fi

  chmod 0744 $VDRSCRIPTDIR/queuehandler.sh
  chown $VDRUSER.$VDRGROUP $VDRSCRIPTDIR/queuehandler.sh
  chown $VDRUSER.$VDRGROUP $VDRSCRIPTDIR/queuehandler.sh.conf
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
