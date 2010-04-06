#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 12.03.2009
#
# vdr-image

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/vdr-image/vdr-image-0.3.0.tar.gz"
VERSION="image-0.3.0"
LINK="image"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRSCRIPTDIR/imageplugin.sh
  rm -f $VDRSCRIPTDIR/magickplugin.sh
  rm -f $VDRCONFDIR/imagecmds.conf
  rm -f $VDRCONFDIR/imagesources.conf
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
  # scripte
  cp -f $DIR/imageplugin.sh $VDRSCRIPTDIR
  cp -f $DIR/magickplugin.sh $VDRSCRIPTDIR
  chmod 0744 $VDRSCRIPTDIR/imageplugin.sh $VDRSCRIPTDIR/magickplugin.sh
  # imagecmds.conf
  cp -f $DIR/imagecmds.conf $VDRCONFDIR/plugins
  # imagesources.conf
  if [ -f $DIR/imagesources.conf ]; then
    cp -f $DIR/imagesources.conf $VDRCONFDIR/plugins
  else
    {
      echo "$PICTUREDIR;Fotos;0;*.jpg *.JPG"
      echo "$VDRCONFDIR/plugins/burn;Hintergruende fuer Burn;0;*.png"
      echo "/tmp;Screenshots;0;*.jpg *.JPG"
      echo "/media/usb;USB-Stick;1;*.jpg *.JPG"
      echo ""
    } > $VDRCONFDIR/plugins/imagesources.conf
  fi

  chown $VDRUSER:$VDRGROUP $VDRSCRIPTDIR/imageplugin.sh $VDRSCRIPTDIR/magickplugin.sh $VDRCONFDIR/plugins/imagecmds.conf $VDRCONFDIR/plugins/imagesources.conf
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
