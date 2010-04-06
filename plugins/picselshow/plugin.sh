#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 03.06.2007
#
# vdr-picselshow

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.glaserei-franz.de/VDR/Moronimo2/files/moron-suite-0.0.2.tar.bz2"
VERSION="picselshow-0.0.2"
LINK="picselshow"
VAR_picsel="vdr-picselshow-0.0.2.tar.gz"

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

  if [ ! -f "$FILES/plugins/$VAR_picsel" ] && [ -f "$FILES/plugins/$VAR" ]; then
    [ -d "$FILES/plugins/moron" ] && rm -rf $FILES/plugins/moron
    tar xjf "$FILES/plugins/$VAR" -C "$FILES/plugins"
    mv -f $FILES/plugins/moron/vdr-*.tar.gz $FILES/plugins
    [ -d "$FILES/plugins/moron" ] && rm -rf $FILES/plugins/moron
  fi
  VAR="$VAR_picsel"

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
