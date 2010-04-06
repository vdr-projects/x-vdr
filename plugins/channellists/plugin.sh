#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 20.02.2008
#
# vdr-channellists

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://www.zulu-entertainment.de/files/vdr-channellists/vdr-channellists-0.0.4.tgz"
VERSION="channellists-0.0.4"
LINK="channellists"

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
  if [ -d $DIR/channellists ]; then
    cp -rf $DIR/channellists $VDRCONFDIR/plugins
    chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/channellists
  fi
  if [ -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/scripts/channellists-update.sh ]; then
    cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/scripts/channellists-update.sh $VDRSCRIPTDIR
    chown $VDRUSER:$VDRGROUP $VDRSCRIPTDIR/channellists-update.sh
    chmod 0744 $VDRSCRIPTDIR/channellists-update.sh
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
