#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 05.05.2008
#
# vdr-freecell

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdr-wiki.de/vdr/vdr-freecell/vdr-freecell-0.0.2.tgz"
VERSION="freecell-0.0.2"
LINK="freecell"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -rf $VDRCONFDIR/plugins/freecell
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
  if [ -d $DIR/freecell ]; then
    cp -fR $DIR/freecell $VDRCONFDIR/plugins
  else
    cp -fR $SOURCEDIR/VDR/PLUGINS/src/$LINK/freecell $VDRCONFDIR/plugins
  fi
  # rechte setzen
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/freecell
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
