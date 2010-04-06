#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 17.01.2008
#
# vdr-autosort

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/vdr-autosort/vdr-autosort-0.1.3.tgz"
VERSION="autosort-0.1.3"
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
    cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/examples/autosort.conf $VDRCONFDIR/plugins
  fi
  chown $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/autosort.conf
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
