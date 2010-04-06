#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 19.03.2007
#
# vdr-filebrowser

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://www.stud.uni-karlsruhe.de/~uqg8/vdr/filebrowser/vdr-filebrowser-0.0.6b.tgz"
VERSION="filebrowser-0.0.6b"
LINK="filebrowser"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -rf $VDRCONFDIR/plugins/filebrowser
  rm -f $VDRSCRIPTDIR/burniso
  rm -f $VDRSCRIPTDIR/cdrip
  rm -f $VDRSCRIPTDIR/recode
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
  cp -rf $SOURCEDIR/VDR/PLUGINS/src/$LINK/examples/filebrowser $VDRCONFDIR/plugins
  [ -f $DIR/commands.conf ] && cp -f $DIR/commands.conf $VDRCONFDIR/plugins/filebrowser
  chown -R $VDRUSER.$VDRGROUP $VDRCONFDIR/plugins/filebrowser

  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/examples/scripts/burniso $VDRSCRIPTDIR
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/examples/scripts/cdrip $VDRSCRIPTDIR
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/examples/scripts/recode $VDRSCRIPTDIR
  chmod 0744 $VDRSCRIPTDIR/burniso
  chmod 0744 $VDRSCRIPTDIR/cdrip
  chmod 0744 $VDRSCRIPTDIR/recode
  chown $VDRUSER:$VDRGROUP $VDRSCRIPTDIR/burniso $VDRSCRIPTDIR/cdrip  $VDRSCRIPTDIR/recode
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
