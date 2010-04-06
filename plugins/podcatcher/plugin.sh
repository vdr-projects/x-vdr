#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 30.01.2009
#
# vdr-podcatcher

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdr-wiki.de/vdr/vdr-podcatcher/vdr-podcatcher-0.1.1.tar.gz"
VERSION="podcatcher-0.1.1"
LINK="podcatcher"

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
  patch_p1_plugin

  ## plugin specials - start ##
  mkdir -p /var/cache/podcatcher
  chown -R $VDRUSER:$VDRGROUP /var/cache/podcatcher
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/examples/podcatchersources.conf $VDRCONFDIR/plugins
  chown $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/podcatchersources.conf
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
