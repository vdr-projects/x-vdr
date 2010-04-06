#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 27.06.2007
#
# vdr-text2skin

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://brougs78.vdr-developer.org/tmp/vdr-text2skin-1.1-cvs_ext-0.10.tgz"
#WEB="http://www.zulu-entertainment.de/files/vdr-text2skin/vdr-text2skin-1.1-cvs_ext-0.10-patched-20070513.tar.bz2"
VERSION="text2skin-1.1-cvs_ext-0.10"
LINK="text2skin"
CVS="0"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -rf $VDRCONFDIR/plugins/text2skin
  log "cleaning $LINK"
}

# plugin installieren
function install_plugin() {
  if [ "$CVS" = "1" ] ; then
    rm -rf text2skin text2skin-cvs
    echo "CVS password: [Just press enter]"
    cvs -d:pserver:anoncvs@vdr-developer.org:/var/cvsroot login
    cvs -d:pserver:anoncvs@vdr-developer.org:/var/cvsroot -z3 co text2skin
    mv -f text2skin text2skin-cvs
    cp -R text2skin-cvs $SOURCEDIR/VDR/PLUGINS/src
  else
    download_plugin
    extract_plugin
  fi
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -f $LINK
  ln -vfs $VERSION $LINK
  patch_plugin
  patch_p1_plugin

  ## plugin specials - start ##
# install skins
  log "*******************************"
  log "Installation der Skins ..."
  log "*******************************"
  cd $DIR/skins
  chmod 0744 ./install-skins.sh
  if ./install-skins.sh; then
    log "*******************************"
    log "... der Skins ist abgeschlossen"
    log "*******************************"
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
