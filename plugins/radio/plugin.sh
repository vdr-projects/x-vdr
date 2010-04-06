#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 23.10.2007
#
# vdr-radio

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://www.egal-vdr.de/plugins/vdr-radio-0.2.4.tgz"
VERSION="radio-0.2.4"
LINK="radio"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -rf $VDRCONFDIR/plugins/radio
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
  [ ! -d $VDRCONFDIR/plugins/radio ] && mkdir -p $VDRCONFDIR/plugins/radio
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/config/mpegstill/* $VDRCONFDIR/plugins/radio
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/radio
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
