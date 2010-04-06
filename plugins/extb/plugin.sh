#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 08.03.2009
#
# vdr-extb

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/vdr-extb/vdr-extb-0.3.1.tgz"
VERSION="extb-0.3.1"
LINK="extb"

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
  vdrconfdir_new="my \$CONFIGFILE = \"$VDRCONFDIR/extb-poweroff.conf\";"
  vdrconfdir_old=$(grep -m 1 '^my $CONFIGFILE = ' $DIR/extb-poweroff.pl)
  [ "$vdrconfdir_new" != "$vdrconfdir_old" ] && sed -i $DIR/extb-poweroff.pl -e "s?$vdrconfdir_old?$vdrconfdir_new?g"
  cp -f $DIR/extb-poweroff.conf $VDRCONFDIR
  cp -f $DIR/extb-poweroff.pl $VDRSCRIPTDIR
  chmod 744 $VDRSCRIPTDIR/extb-poweroff.pl
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
