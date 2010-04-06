#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 23.01.2009
#
# vdr-muggle

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://projects.vdr-developer.org/attachments/download/53/vdr-muggle-0.2.3.tgz"
VERSION="muggle-0.2.3"
LINK="muggle"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRBINDIR/image_convert.sh
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
  apt_install "sqlite3 libsqlite3-dev"
  # oder Patch entfernen und...
#  apt_install "libmysqlclient15-dev mysql-server mysql-client"

  apt_install "libmad0-dev libtag1-dev libvorbis-dev"
  apt_install "libwrap0-dev"
  # Googlyric2 Beta 3 und Python
  apt_install "python"
  if [ -f /usr/share/apps/amarok/scripts/Googlyrics2.Beta3.amarokscript.tar.gz ]; then
    echo "Googlyrics vorhanden"
  else
    cd /usr/share/apps
    mkdir amarok
    mkdir amarok/scripts
    cd /usr/share/apps/amarok/scripts/
    wget http://quicode.com/Googlyrics2.Beta3.amarokscript.tar.gz
    tar -xzf Googlyrics2.Beta3.amarokscript.tar.gz
  fi
  mkdir $VDRCONFDIR/plugins/$LINK
  mkdir $VDRCONFDIR/plugins/$LINK/scripts
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/scripts/* $VDRCONFDIR/plugins/$LINK/scripts
  chmod 0755 $VDRCONFDIR/plugins/$LINK/scripts/muggle_getlyrics
  chmod 0755 $VDRCONFDIR/plugins/$LINK/scripts/*.py

  # scripts
  if [ -f $DIR/muggle-image-convert ]; then
    cp -f $DIR/muggle-image-convert $VDRBINDIR
  else
    cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/scripts/muggle-image-convert $VDRBINDIR
  fi
  chmod 0755 $VDRBINDIR/muggle-image-convert
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
