#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 26.01.2009
#
# vdr-coverviewer

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.glaserei-franz.de/VDR/Moronimo2/files/vdr-coverviewer-1.0.0-b1.tgz"
VERSION="coverviewer-1.0.0-b1"
LINK="coverviewer"
VAR_cover="vdr-coverviewer-1.0.0-b1.tgz"

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

  if [ ! -f "$FILES/plugins/$VAR_cover" ] && [ -f "$FILES/plugins/$VAR" ]; then
    [ -d "$FILES/plugins/moron" ] && rm -rf $FILES/plugins/moron
    tar xjf "$FILES/plugins/$VAR" -C "$FILES/plugins"
    mv -f $FILES/plugins/moron/vdr-*.tar.gz $FILES/plugins
    [ -d "$FILES/plugins/moron" ] && rm -rf $FILES/plugins/moron
  fi
  VAR="$VAR_cover"

  extract_plugin
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -f $LINK
  ln -vfs $VERSION $LINK
  patch_plugin

  ## plugin specials - start ##
  # Verzeichnis coverviewer und music kopieren
  cp -r $SOURCEDIR/VDR/PLUGINS/src/$LINK/coverviewer $VDRCONFDIR/plugins/
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/coverviewer
  cp -r $SOURCEDIR/VDR/PLUGINS/src/$LINK/music $VDRCONFDIR/plugins/
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/music
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
