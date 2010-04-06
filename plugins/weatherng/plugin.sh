#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 21.05.2008
#
# vdr-weatherng

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdr.glaserei-franz.de/files/vdr-weatherng-0.0.10.tar.bz2"
VERSION="weatherng-0.0.10"
LINK="weatherng"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -rf $VDRCONFDIR/plugins/weatherng
  rm -f $VDRSCRIPTDIR/weatherng.sh
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

  # config kopieren
  if [ -d $DIR/images ]; then
    cp -fR $DIR/weatherng $VDRCONFDIR/plugins
  else
    cp -fR $SOURCEDIR/VDR/PLUGINS/src/$LINK/weatherng/weatherng $VDRCONFDIR/plugins/weatherng
  fi

  # script kopieren
  if [ -f $DIR/weatherng.sh ]; then
    cp -f $DIR/weatherng.sh $VDRSCRIPTDIR
  else
    cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/examples/weatherng.sh $VDRSCRIPTDIR
  fi

  # rechte setzen
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/weatherng
  chown $VDRUSER:$VDRGROUP $VDRSCRIPTDIR/weatherng.sh
  chmod 0744 $VDRSCRIPTDIR/weatherng.sh
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
