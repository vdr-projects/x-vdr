#!/bin/sh

# x-vdr (vdr-installer für kanotix)
# von Marc Wernecke - www.zulu-entertainment.de
# 10.06.2007
#
# vdr-touchtft

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://downloads.htpc-tech.de/touchtft/vdr-touchtft-0.0.4.tar.gz"
VERSION="touchtft-0.0.4"
LINK="touchtft"

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
