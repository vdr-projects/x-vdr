#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 01.05.2008
#
# vdr-alcd

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.htpc-forum.de/download/vdr-alcd-1.3.0.tgz"
VERSION="alcd-1.3.0"
LINK="alcd"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  unfreeze_rc
  update-rc.d -f activy remove && log "Disable Autostart for: activy"
  freeze_rc
  rm -f /etc/init.d/activy
  rm -f $VDRSCRIPTDIR/activy*.sh
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
  cp -f $DIR/scripts/activy /etc/init.d
  chmod 0755 /etc/init.d/activy
  unfreeze_rc
  update-rc.d activy defaults 98 && log "Enable Autostart for: activy"
  freeze_rc
  cp -f $DIR/scripts/*.sh $VDRSCRIPTDIR
  chown $VDRUSER:$VDRGROUP $VDRSCRIPTDIR/activy*.sh
  chmod 0744  $VDRSCRIPTDIR/activy*.sh
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
