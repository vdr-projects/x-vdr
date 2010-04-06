#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 21.02.2009
#
# vdr-setup

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/vdr-setup/vdr-setup-0.3.1-zulu-edition.tgz"
VERSION="setup-0.3.1-zulu-edition"
LINK="setup"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -rf $VDRCONFDIR/plugins/setup
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

  ## plugin specials - start ##
  [ "$VDRUPDATE" = "on" ] && [ -d $VDRCONFDIR/plugins/setup ] && return

  cp -rf $DIR/setup $VDRCONFDIR/plugins
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/setup
  chmod 0744 $VDRCONFDIR/plugins/setup/*.xml
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
