#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 05.05.2008
#
# vdr-manual

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdr-wiki.de/vdr/vdr-manual/vdr-manual-0.0.3.tgz"
VERSION="manual-0.0.3"
LINK="manual"

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
  if [ -d $DIR/manual ]; then
    cp -fR $DIR/manual $VDRCONFDIR/plugins
  else
    cp -fR $SOURCEDIR/VDR/PLUGINS/src/$LINK/manual $VDRCONFDIR/plugins
  fi
  # rechte setzen
  chown -R $VDRUSER.$VDRGROUP $VDRCONFDIR/plugins/manual
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
