#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 23.03.2009
#
# vdr-softdevice

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/vdr-softdevice/vdr-softdevice-0.5.0-cvs20090323.tgz"
VERSION="softdevice-0.5.0"
LINK="softdevice"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRLIBDIR/libsoftdevice-*
  rm -f $VDRBINDIR/ShmClient
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
  configure_conf="--disable-subplugins"

  if [ -f $PREFIX/include/vidix/fourcc.h ] && [ -f $PREFIX/include/vidix/vidix.h ] && [ -f $PREFIX/include/vidix/vidixlib.h ]; then
    configure_conf="$configure_conf --with-vidix-path $PREFIX"
  fi

  if [ "$yaepg" = "on" ]; then
    configure_conf="$configure_conf --enable-yaepg"
  else
    configure_conf="$configure_conf --disable-yaepg"
  fi

  cd $SOURCEDIR/VDR/PLUGINS/src/$LINK
  ./configure $configure_conf
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

# install ShmClient
if [ "$cmd" = "-m" ] || [ "$cmd" = "--make" ] || [ "$cmd" = "-r" ] || [ "$cmd" = "--remake" ]; then
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/ShmClient $VDRBINDIR
  chmod 0755 $VDRBINDIR/ShmClient
fi

exit 0
