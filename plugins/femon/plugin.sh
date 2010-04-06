#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 07.01.2009
#
# vdr-femon

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

if [ "${VDRVERSION:2:1}" = "6" ]; then
  WEB="http://www.saunalahti.fi/~rahrenbe/vdr/femon/files/vdr-femon-1.6.6.tgz"
  VERSION="femon-1.6.6"
else
  WEB="http://www.saunalahti.fi/~rahrenbe/vdr/femon/files/vdr-femon-1.7.1.tgz"
  VERSION="femon-1.7.1"
fi

LINK="femon"

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
