#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 11.03.2006
#
# vdr-graphlcd

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://download.berlios.de/graphlcd/vdr-graphlcd-0.1.5.tgz"
VERSION="graphlcd-0.1.5"
LINK="graphlcd"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $VDRCONFDIR/plugins/graphlcd
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
  # copy data
  cd $SOURCEDIR/VDR/PLUGINS/src/$LINK
  cp -r graphlcd $VDRCONFDIR/plugins

  # symlink fuer logos und fonts
  cd $VDRCONFDIR/plugins/graphlcd
  ln -sf logonames.alias.1.3 logonames.alias
  ln -sf fonts.conf.small fonts.conf

  # media
  cd $DIR
  local WEB="http://www.zulu-entertainment.de/files/vdr-graphlcd/graphlcd-media-snapshot-20060828.tar.gz"
  local VERSION="graphlcd-media-snapshot-20060828"
  local VAR=`basename $WEB`
  download_plugin
  if echo "$FILES/plugins/$VAR" | grep "bz2$" - &>/dev/null; then
    if tar xjf "$FILES/plugins/$VAR" -C $DIR; then log "extrahiere $VAR" ; fi
  else
    if tar xzf "$FILES/plugins/$VAR" -C $DIR; then log "extrahiere $VAR" ; fi
  fi
  cp -r $DIR/$VERSION/* $VDRCONFDIR/plugins/graphlcd

  # rechte
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/graphlcd
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
