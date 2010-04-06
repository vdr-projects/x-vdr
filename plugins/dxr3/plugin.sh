#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 06.01.2009
#
# vdr-dxr3

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/vdr-dxr3/vdr-dxr3-0.2.9.tgz"
VERSION="dxr3-0.2.9"
LINK="dxr3"

CVS="0"
[ "$CVS" = "1" ] && VERSION="dxr3-cvs"

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
  if [ "$CVS" = "1" ]; then
    cd $DIR
    echo "CVS password: [Just press enter]"
    echo ""
    cvs -d:pserver:anonymous@dxr3plugin.cvs.sourceforge.net:/cvsroot/dxr3plugin login
    cvs -d:pserver:anonymous@dxr3plugin.cvs.sourceforge.net:/cvsroot/dxr3plugin co -r vdr-dxr3-0-2 dxr3
    cp -R dxr3 $SOURCEDIR/VDR/PLUGINS/src/$VERSION
  else
    # download plugin
    download_plugin
    # extrahiere plugin
    extract_plugin
  fi
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -f $LINK
  ln -vfs $VERSION $LINK
  patch_plugin

  ## plugin specials - start ##
  # Scripte kopieren
  cp -f $SOURCEDIR/x-vdr/utilities/em8300/ldm $VDRSCRIPTDIR
  chmod 0744 $VDRSCRIPTDIR/ldm

  cp -f $SOURCEDIR/x-vdr/utilities/em8300/rmm $VDRSCRIPTDIR
  chmod 0744 $VDRSCRIPTDIR/rmm

  chown $VDRUSER:$VDRGROUP $VDRSCRIPTDIR/ldm $VDRSCRIPTDIR/rmm
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
