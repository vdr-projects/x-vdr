#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 03.05.2007
#
# vdr-digicam

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://www.unterbrecher.de/vdr/download/vdr-digicam-1.0.2.tgz"
VERSION="digicam-1.0.2"
LINK="digicam"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRCONFDIR/plugins/digicamdestinations.conf
  rm -f $VDRCONFDIR/plugins/digicamsources.conf
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
#  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/examples/digicamdestinations.conf $VDRCONFDIR/plugins
  echo "#
# This is a example of digicamdestinations.conf with usually using and sample entrys.
#
# This file should placed on VDR configuration folder with setup.conf
#  .../setup.conf
#  .../plugins/digicamdestinations.conf 
#
# Syntax is: <path>;<name>;<mount>;<filter>
#
# <path>   = Path, where to copy images or image directories from the camera
# <name>   = descriptor displayed in VDR
# <mount>  = 0 - if no mounting should be done
#            1 - if <path> needs to be mounted first. 
#                (Dont forget to setup fstab !!!)
# <filter> = currently not used
#
$PICTUREDIR;Fotos;0;
" > $VDRCONFDIR/plugins/digicamdestinations.conf
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/examples/digicamsources.conf $VDRCONFDIR/plugins
  chown $VDRUSER.$VDRGROUP $VDRCONFDIR/plugins/digicamdestinations.conf $VDRCONFDIR/plugins/digicamsources.conf
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
