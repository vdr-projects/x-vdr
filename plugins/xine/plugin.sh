#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 12.04.2009
#
# vdr-xine

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://home.vrweb.de/~rnissl/vdr-xine-0.9.1.tgz"
VERSION="xine-0.9.1"
LINK="xine"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK
  rm -rf $VERSION
  rm -f $VDRLIBDIR/libvdr-$LINK.so*
  rm -rf $VDRCONFDIR/plugins/xine
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
  cd $SOURCEDIR/VDR/PLUGINS/src/$LINK
  # Kopieren der "loops"
  mkdir -p $VDRCONFDIR/plugins/xine
  find . -name *.mpg -exec cp -v \{} $VDRCONFDIR/plugins/xine \;
  # link fuer den Player
  ln -vfs $(pwd)/xineplayer $PREFIX/bin/xineplayer

  # xinplayer.sh fuer divx und dvd
  if [ -f $DIR/xineplayer.sh ]; then
    cp -f $DIR/xineplayer.sh $VDRSCRIPTDIR
    chown $VDRUSER:$VDRGROUP $VDRSCRIPTDIR/xineplayer.sh
    chmod 0744 $VDRSCRIPTDIR/xineplayer.sh
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
