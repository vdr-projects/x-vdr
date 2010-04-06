#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 20.07.2008
#
# vdr-vompserver

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

VOMP_VERSION="0.3.0"
WEB="http://www.loggytronic.com/dl/vdr-vompserver-${VOMP_VERSION}.tgz"
VERSION="vompserver-${VOMP_VERSION}"
LINK="vompserver"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -rf $VDRCONFDIR/plugins/vompserver
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
  cd $DIR
  WEB="http://www.loggytronic.com/dl/vomp-dongle-${VOMP_VERSION}"
  VAR=`basename $WEB`
  download_plugin
  cp -rf $DIR/vompserver $VDRCONFDIR/plugins
  cp -rf $SOURCEDIR/VDR/PLUGINS/src/vompserver/l10n $VDRCONFDIR/plugins/vompserver
  cp -f $FILES/plugins/vomp-dongle-${VOMP_VERSION} $VDRCONFDIR/plugins/vompserver/vomp-dongle
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/vompserver
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
