#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 05.05.2008
#
# vdr-loadepg

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdr-wiki.de/vdr/vdr-loadepg/vdr-loadepg-0.1.12.tgz"
VERSION="loadepg-0.1.12"
LINK="loadepg"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -rf $VDRCONFDIR/plugins/loadepg
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
  [ ! -d $VDRCONFDIR/plugins/loadepg ] && mkdir -p $VDRCONFDIR/plugins/loadepg
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/loadepg.conf $VDRCONFDIR/plugins/loadepg
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/loadepg.equiv $VDRCONFDIR/plugins/loadepg
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
