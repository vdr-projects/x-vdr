#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 03.03.2009
#
# vdr-vodcatcher

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.e-tobi.net/blog/files/vdr-vodcatcher-0.2.1.tar.gz"
VERSION="vodcatcher-0.2.1"
LINK="vodcatcher"

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
  [ -f $DIR/vodcatchersources.conf ] && cp -f $DIR/vodcatchersources.conf $VDRCONFDIR/plugins
  [ -d /var/cache/vdr-plugin-vodcatcher ] || mkdir -p /var/cache/vdr-plugin-vodcatcher
  chown $VDRUSER:$VDRGROUP /var/cache/vdr-plugin-vodcatcher
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
