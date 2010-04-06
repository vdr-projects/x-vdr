#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 05.05.2008
#
# vdr-decruft

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdr-wiki.de/vdr/vdr-decruft/vdr-decruft-0.0.4.tgz"
VERSION="decruft-0.0.4"
LINK="decruft"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRCONFDIR/plugins/decruft.conf
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
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/examples/decruft.conf $VDRCONFDIR/plugins
  chown $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/decruft.conf
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
