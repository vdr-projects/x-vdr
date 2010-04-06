#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 30.03.2006
#
# vdr-submenu

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://www.freewebs.com/sadhome/Plugin/SubMenu/vdr-submenu-0.0.2.tar.gz"
VERSION="submenu-0.0.2"
LINK="submenu"

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
  if [ -f $DIR/MainMenu.conf ]; then 
    cp -f $DIR/MainMenu.conf $VDRCONFDIR/plugins
    chown $VDRUSER.$VDRGROUP $VDRCONFDIR/plugins/MainMenu.conf
  fi
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
