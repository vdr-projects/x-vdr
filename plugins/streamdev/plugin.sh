#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 07.04.2009
#
# vdr-streamdev

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/vdr-streamdev/vdr-streamdev-0.5.0-pre.tgz"
VERSION="streamdev-0.5.0-pre"
LINK="streamdev"
CVS="0"

[ "$CVS" = "1" ] && VERSION="streamdev-cvs"

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
  if [ "$CVS" = "1" ] ; then
    cd $DIR
    rm -rf streamdev $VERSION
    echo "CVS password: [Just press enter]"
    cvs -d:pserver:anoncvs@vdr-developer.org:/var/cvsroot login
    cvs -d:pserver:anoncvs@vdr-developer.org:/var/cvsroot co streamdev
    mv -f streamdev $VERSION
    cp -R $VERSION $SOURCEDIR/VDR/PLUGINS/src
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
  [ -d $VDRCONFDIR/plugins/streamdev ] || mkdir -p $VDRCONFDIR/plugins/streamdev

  if [ -f $VDRCONFDIR/plugins/streamdevhosts.conf ]; then 
    mv $VDRCONFDIR/plugins/streamdevhosts.conf $VDRCONFDIR/plugins/streamdev/streamdevhosts.conf
  elif [ -f $DIR/streamdevhosts.conf ]; then 
    cp $DIR/streamdevhosts.conf $VDRCONFDIR/plugins/streamdev
  else
    cp $VDRCONFDIR/svdrphosts.conf $VDRCONFDIR/plugins/streamdev/streamdevhosts.conf
  fi

  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/streamdev
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
