#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 02.03.2009
#
# vdr-sndctl

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/vdr-sndctl/vdr-sndctl-0.1.3.tgz"
VERSION="sndctl-0.1.3"
LINK="sndctl"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK
  rm -rf $VERSION
  rm -f $VDRLIBDIR/libvdr-$LINK.so*
  log "cleaning $LINK"
}

# plugin installieren
function install_plugin() {
  ### DAMIT DAS PLUGIN INSTALLIERT WERDEN KANN, MUSS DIE FOLGENDE ZEILE ENTFERNT WERDEN
  log "$VERSION ist fehlerhaft, editiere die plugin.sh um das Plugin trotzdem zu installieren" && exit 1

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
