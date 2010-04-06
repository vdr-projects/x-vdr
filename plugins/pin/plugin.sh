#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 06.06.2007
#
# vdr-pin

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://www.jwendel.de/vdr/vdr-pin-0.1.9.tgz"
VERSION="pin-0.1.9"
LINK="pin"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRSCRIPTDIR/fskprotect.sh
  rm -f $VDRBINDIR/fskcheck
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
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/scripts/fskprotect.sh $VDRSCRIPTDIR
  chmod 0744 $VDRSCRIPTDIR/fskprotect.sh
  chown $VDRUSER:$VDRGROUP $VDRSCRIPTDIR/fskprotect.sh
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

# install fskcheck
if [ "$cmd" = "-m" ] || [ "$cmd" = "--make" ] || [ "$cmd" = "-r" ] || [ "$cmd" = "--remake" ]; then
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/fskcheck $VDRBINDIR
  chmod 0755 $VDRBINDIR/fskcheck
fi

exit 0
