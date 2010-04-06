#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 07.01.2009
#
# vdr-skinsoppalusikka

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.saunalahti.fi/~rahrenbe/vdr/soppalusikka/files/vdr-skinsoppalusikka-1.6.3.tgz"
VERSION="skinsoppalusikka-1.6.3"
LINK="skinsoppalusikka"

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
  if [ ! -d "$VDRCONFDIR/logos" ]; then
    if [ -d $VDRCONFDIR/plugins/skinenigmang/logos ]; then
      cp -rd $VDRCONFDIR/plugins/skinenigmang/logos $VDRCONFDIR
    else
      mkdir -p $VDRCONFDIR/logos
    fi
  fi
  cp $SOURCEDIR/VDR/PLUGINS/src/$LINK/themes/*.theme $VDRCONFDIR/themes
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/logos $VDRCONFDIR/themes
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
