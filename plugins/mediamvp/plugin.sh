#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 21.12.2006
#
# vdr-mediamvp

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://www.rst38.org.uk/mediamvp/vdr-mediamvp-0.1.6.tgz"
VERSION="mediamvp-0.1.6"
LINK="mediamvp"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRLIBDIR/libvdr-mvp*
  rm -f $VDRCONFDIR/plugins/httpradio.conf
  rm -f $VDRCONFDIR/plugins/mvprss.conf
  rm -f $VDRCONFDIR/plugins/picturesources.conf
  rm -f /etc/init.d/runmvp
  rm -f $VDRBINDIR/mvploader
  rm -rf $VDRCONFDIR/plugins/mediamvp
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
  cp -f $DIR/config.mak $SOURCEDIR/VDR/PLUGINS/src/$LINK

  cp -f $DIR/httpradio.conf $VDRCONFDIR/plugins
  cp -f $DIR/mvprss.conf $VDRCONFDIR/plugins
  # picturesources.conf
  if [ -f $DIR/picturesources.conf ]; then
    cp -f $DIR/picturesources.conf $VDRCONFDIR/plugins
  else
    {
      echo "$PICTUREDIR;Fotos;0;*.jpg/*.JPG"
      echo ""
    } > $VDRCONFDIR/plugins/picturesources.conf
  fi

  cp -f $DIR/runmvp /etc/init.d
  chmod 0755 /etc/init.d/runmvp
  #update-rc.d runmvp defaults 99

  cp -f $DIR/mvploader $VDRBINDIR

  mkdir -p $VDRCONFDIR/plugins/mediamvp
  [ -f $DIR/dongle.bin ] && cp -f $DIR/dongle.bin $VDRCONFDIR/plugins/mediamvp
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
