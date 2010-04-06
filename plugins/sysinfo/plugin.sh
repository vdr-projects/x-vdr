#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 05.05.2008
#
# vdr-sysinfo

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdr-wiki.de/vdr/vdr-sysinfo/vdr-sysinfo-0.1.0a.tgz"
VERSION="sysinfo-0.1.0a"
LINK="sysinfo"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRBINDIR/sysinfo.sh
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
  if [ -f $DIR/sysinfo.sh ] ; then
    cp -f $DIR/sysinfo.sh $VDRBINDIR
  else
    cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/script/sysinfo.sh $VDRBINDIR
  fi
  chmod 0755 $VDRBINDIR/sysinfo.sh
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
