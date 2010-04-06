#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 30.03.2006
#
# vdr-solitaire

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://vdr.bluox.org/download/vdr-solitaire/vdr-solitaire-0.0.2.tgz"
VERSION="solitaire-0.0.2"
LINK="solitaire"

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
  # karten kopieren
  cp -R $SOURCEDIR/VDR/PLUGINS/src/solitaire/solitaire $VDRCONFDIR/plugins
  chown -R $VDRUSER.$VDRGROUP $VDRCONFDIR/plugins/solitaire
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
