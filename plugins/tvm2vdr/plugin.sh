#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 23.02.2009
#
# vdr-tvm2vdr

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://download.origo.ethz.ch/vdr-plugin-tvm2vdr/1018/vdr-tvm2vdr-0.0.2.tgz"
VERSION="tvm2vdr-0.0.2"
LINK="tvm2vdr"

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
  [ "$VDRUPDATE" = "on" ] && [ -d $VDRCONFDIR/plugins/tvm2vdr ] && return
  if [ -d "$DIR/tvm2vdr" ]; then
    cp -rf $DIR/tvm2vdr $VDRCONFDIR/plugins
  else
    [ -d "$VDRCONFDIR/plugins/tvm2vdr" ] || mkdir -p $VDRCONFDIR/plugins/tvm2vdr
    cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/tvm2vdr_channelmap.conf $VDRCONFDIR/plugins/tvm2vdr
    cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/*.xsl $VDRCONFDIR/plugins/tvm2vdr
  fi
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/tvm2vdr
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
