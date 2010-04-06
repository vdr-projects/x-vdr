#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 05.05.2008
#
# vdr-autosort

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdr-wiki.de/vdr/vdr-autosort/vdr-autosort-0.0.10.tgz"
VERSION="autosort-0.0.10"
LINK="autosort"

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
  if [ -f $DIR/autosort.conf ]; then
    cp -f $DIR/autosort.conf $VDRCONFDIR/plugins
  else
    cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/autosort.conf $VDRCONFDIR/plugins
  fi
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
