#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 10.01.2009
#
# vdr-epgsearch

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://winni.vdr-developer.org/epgsearch/downloads/beta/vdr-epgsearch-0.9.25.beta7.tgz"
VERSION="epgsearch-0.9.25.beta7"
LINK="epgsearch"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-epgsearch
  rm -f $VDRLIBDIR/libvdr-conflictcheckonly
  rm -f $VDRLIBDIR/libvdr-epgsearchonly
  rm -f $VDRLIBDIR/libvdr-quickepgsearch
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
  [ ! -d $VDRCONFDIR/plugins/epgsearch ] && mkdir -p $VDRCONFDIR/plugins/epgsearch

  cp -f $SOURCEDIR/VDR/PLUGINS/src/epgsearch/conf/epgsearchconflmail.templ $VDRCONFDIR/plugins/epgsearch
  cp -f $SOURCEDIR/VDR/PLUGINS/src/epgsearch/conf/epgsearchupdmail.templ $VDRCONFDIR/plugins/epgsearch
  cp -f $SOURCEDIR/VDR/PLUGINS/src/epgsearch/scripts/sendEmail.pl $VDRBINDIR
  chmod 0755 $VDRBINDIR/sendEmail.pl

  if [ "$graphtft" = "on" ] && [ -f $DIR/epgsearchmenu_graphtft.conf ] && [ ! -f $VDRCONFDIR/plugins/epgsearch/epgsearchmenu.conf ]; then
    cp -f $DIR/epgsearchmenu_graphtft.conf $VDRCONFDIR/plugins/epgsearch/epgsearchmenu.conf
  else
    cp -f $DIR/epgsearchmenu.conf $VDRCONFDIR/plugins/epgsearch
  fi

  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/epgsearch
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
