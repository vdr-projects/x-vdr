#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 29.05.2008
#
# vdr-mp3

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
WEB="http://www.muempf.de/down/vdr-mp3-0.10.1.tar.gz"
VERSION="mp3-0.10.1"
LINK="mp3"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK
  rm -rf $VERSION
  rm -f $VDRLIBDIR/libvdr-$LINK.so*
  rm -f $VDRLIBDIR/libvdr-mplayer.so*
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

  # mp3sources.conf
  if [ -f $DIR/mp3sources.conf ]; then 
    cp -f $DIR/mp3sources.conf $VDRCONFDIR/plugins
  else
    {
      echo "$MUSICDIR;Locale Platte;0;*.mp3/*.ogg/*.wav"
      echo "/media/usb;USB-Stick;1;*.mp3/*.ogg/*.wav"
      echo "/media/cdrom;CDROM;1;*.mp3/*.ogg/*.wav"
      echo "/media/cdfs;CD-Audio;1;*.wav"
      echo ""
    } > $VDRCONFDIR/plugins/mp3sources.conf
  fi
  chown $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/mp3sources.conf

  # mplayersources.conf
  if [ -f $DIR/mplayersources.conf ]; then
    cp -f $DIR/mplayersources.conf $VDRCONFDIR/plugins
  else
    {
      echo "$DIVXDIR;DivX Filme;0;*.avi"
      echo "$DVDISODIR;DVD Filme;0;*.iso"
      echo "$VIDEODIR;Aufnahmen;0;*0*.vdr"
      echo "$MEDIADIR/DVD-VCD;DVD or VCD;0"
      [ "$vodcatcher" = "on" ] && echo "/tmp;Vodcatcher;0"
      echo "/media/usb;USB-Stick;1"
      echo ""
    } > $VDRCONFDIR/plugins/mplayersources.conf
  fi
  chown $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/mplayersources.conf

  # mplayer
  if [ -f $SOURCEDIR/x-vdr/utilities/mplayer/mplayer.sh ]; then
    cp -f $SOURCEDIR/x-vdr/utilities/mplayer/mplayer.sh $VDRSCRIPTDIR
    cp -f $SOURCEDIR/x-vdr/utilities/mplayer/mplayer.sh.conf $VDRSCRIPTDIR
    chown $VDRUSER:$VDRGROUP $VDRSCRIPTDIR/mplayer.sh $VDRSCRIPTDIR/mplayer.sh.conf
    chmod 0744 $VDRSCRIPTDIR/mplayer.sh
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
