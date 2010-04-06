#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 05.03.2009
#
# vdr-skinelchi

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://firefly.vdr-developer.org/skinelchi/vdr-skinelchi-0.2.0.tar.bz2"
VERSION="skinelchi-0.2.0"
LINK="skinelchi"

VAR=`basename $WEB`
DIR=`pwd`

avardspatch="skinelchi-0.2.0-alpha3_no-avards.diff"

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
  if [ "$avards" != "on" ] && [ -f "$DIR/$avardspatch" ]; then
    cd "$SOURCEDIR/VDR/PLUGINS/src/$LINK"
    echo "apply patch $avardspatch"
    patch < $DIR/$avardspatch
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
