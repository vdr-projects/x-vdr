#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 05.04.2009
#
# vdr-rssreader

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.saunalahti.fi/~rahrenbe/vdr/rssreader/files/vdr-rssreader-1.6.3.tgz"
VERSION="rssreader-1.6.3"
LINK="rssreader"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRCONFDIR/plugins/rssreader.conf
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
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/example/rssreader.conf $VDRCONFDIR/plugins
  chown $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/rssreader.conf
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
