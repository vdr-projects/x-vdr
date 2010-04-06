#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 08.04.2009
#
# vdr-xineliboutput

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
 
if [ "${VDRVERSION:2:1}" = "6" ] || [ "$VDRVERSION" = "1.7.0" ]; then
  WEB="http://downloads.sourceforge.net/xineliboutput/vdr-xineliboutput-1.0.4.tgz"
  VERSION="xineliboutput-1.0.4"
else
  WEB="http://www.zulu-entertainment.de/files/vdr-xineliboutput/vdr-xineliboutput-cvs20090323.tar.bz2"
  VERSION="xineliboutput-cvs20090323"
fi
LINK="xineliboutput"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -f $VDRLIBDIR/libxineliboutput-*
  XINEPLUGINDIR=`xine-config --plugindir`
  [ -f $XINEPLUGINDIR/xineplug_inp_xvdr.so ] && rm -f $XINEPLUGINDIR/xineplug_inp_xvdr.so
  [ -f $XINEPLUGINDIR/post/xineplug_post_audiochannel.so ] && rm -f $XINEPLUGINDIR/post/xineplug_post_audiochannel.so
  [ -f $XINEPLUGINDIR/post/xineplug_post_autocrop.so ] && rm -f $XINEPLUGINDIR/post/xineplug_post_autocrop.so
  [ -f $XINEPLUGINDIR/post/xineplug_post_swscale.so ] && rm -f $XINEPLUGINDIR/post/xineplug_post_swscale.so
  [ -f $VDRBINDIR/vdr-fbfe ] && rm -f $VDRBINDIR/vdr-fbfe
  [ -f $VDRBINDIR/vdr-sxfe ] && rm -f $VDRBINDIR/vdr-sxfe
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
  patch_p1_plugin

  ## plugin specials - start ##

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

# install frontends and xine plugins
if [ "$cmd" = "-m" ] || [ "$cmd" = "--make" ] || [ "$cmd" = "-r" ] || [ "$cmd" = "--remake" ]; then
  cd $SOURCEDIR/VDR/PLUGINS/src/$LINK
  make install
fi

exit 0
