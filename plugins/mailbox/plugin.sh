#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 23.10.2007
#
# vdr-mailbox

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://sites.inka.de/~seca/vdr/download/vdr-mailbox-0.5.0.tgz"
VERSION="mailbox-0.5.0"
LINK="mailbox"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRCONFDIR/plugins/mailbox
  rm -f $VDRSCRIPTDIR/mailcmd.sh
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
  apt_install libc-client-dev
  mkdir -p $VDRCONFDIR/plugins/mailbox
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/mailbox
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/mailcmd.sh $VDRSCRIPTDIR
  chmod 0744 $VDRSCRIPTDIR/mailcmd.sh
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
