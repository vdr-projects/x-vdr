#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 23.06.2007
#
# vdr-ripit

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://www.zulu-entertainment.de/files/vdr-ripit/vdr-ripit-0.0.2.tgz"
VERSION="ripit-0.0.2"
LINK="ripit"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK
  rm -rf $VERSION
  rm -f $VDRLIBDIR/libvdr-$LINK.so*
  log "cleaning $LINK"
}

# plugin installieren
function install_plugin() {
  apt_install "ripit id3 id3v2"
  download_plugin
  extract_plugin
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -f $LINK
  ln -vfs $VERSION $LINK
  patch_plugin

  ## plugin specials - start ##
  [ ! -f "$DIR/ripit.pl.orig" ] && [ -f /usr/bin/ripit.pl ] && cp /usr/bin/ripit.pl $DIR/ripit.pl.orig
  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/commands/ripit.pl /usr/bin
  sed -i "/usr/bin/ripit.pl" -e "s?/VDR/bin/svdrpsend.pl?$VDRBINDIR/svdrpsend.pl?g"
  chmod 0755 /usr/bin/ripit.pl
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
