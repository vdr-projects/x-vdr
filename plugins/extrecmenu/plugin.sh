#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 11.09.2008
#
# vdr-extrecmenu

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://martins-kabuff.de/download/vdr-extrecmenu-1.2-test1.tgz"
VERSION="extrecmenu-1.2"
LINK="extrecmenu"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRBINDIR/dvdarchive.sh
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
  if [ -f $DIR/dvdarchive.sh ]; then
    cp -f $DIR/dvdarchive.sh $VDRBINDIR
  else
    cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/scripts/dvdarchive.sh $VDRBINDIR
  fi
  chmod 0755 $VDRBINDIR/dvdarchive.sh
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
