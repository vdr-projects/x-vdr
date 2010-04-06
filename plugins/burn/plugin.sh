#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 05.03.2009

# vdr-burn

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/vdr-burn/vdr-burn-0.1.0-pre22x.tgz"
VERSION="burn-0.1.0-pre22x"
LINK="burn"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRBINDIR/vdrburn-archive.sh
  rm -f $VDRBINDIR/vdrburn-dvd.sh
  rm -f $VDRBINDIR/burn-buffers
#  rm -f /usr/bin/vdrsync.pl
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

  ## plugin specials - start ############################################################
  # scripte
  if [ -f $DIR/vdrburn-archive.sh ]; then 
    cp -f $DIR/vdrburn-archive.sh $VDRBINDIR
  else
    cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/vdrburn-archive.sh $VDRBINDIR
  fi

  if [ -f $DIR/vdrburn-dvd.sh ]; then 
    cp -f $DIR/vdrburn-dvd.sh $VDRBINDIR
  else
    cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/vdrburn-dvd.sh $VDRBINDIR
  fi

  chmod 0755 $VDRBINDIR/vdrburn-archive.sh
  chmod 0755 $VDRBINDIR/vdrburn-dvd.sh
  chown $VDRUSER.$VDRGROUP $VDRBINDIR/vdrburn-archive.sh $VDRBINDIR/vdrburn-dvd.sh

  if [ -d $DIR/burn ]; then
    cp -rf $DIR/burn $VDRCONFDIR/plugins
  else
    cp -rf $SOURCEDIR/VDR/PLUGINS/src/$LINK/burn $VDRCONFDIR/plugins
  fi

  # vdrsync
  var=`which vdrsync.pl`
  if [ "$var" ]; then
    log "found $var"
  else
    cd $SOURCEDIR/x-vdr/utilities/vdrsync
    chmod 0744 ./utilitie-test.sh
    ./utilitie-test.sh
  fi

  # genindex
  var=`which genindex`
  if [ "$var" ]; then
    log "found $var"
  else
    cd $SOURCEDIR/x-vdr/utilities/genindex
    chmod 0744 ./utilitie-test.sh
    ./utilitie-test.sh
  fi

  # m2vrequantizer
  var=`which requant`
  if [ "$var" ]; then
    log "found $var"
  else
    cd $SOURCEDIR/x-vdr/utilities/m2vrequantizer
    chmod 0744 ./utilitie-test.sh
    ./utilitie-test.sh
  fi

  # rechte setzen
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/burn
  ## plugin specials - ende #############################################################
}

# plugin commands
if [ $# \> 0 ]; then
  cmd=$1
  cmd_plugin
else
  install_plugin
  log "install-plugin fuer $VERSION ist fertig"
fi

# burn-buffer
if [ "$cmd" = "-m" ] || [ "$cmd" = "--make" ] || [ "$cmd" = "-r" ] || [ "$cmd" = "--remake" ]; then
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/burn-buffers $VDRBINDIR
fi

exit 0
