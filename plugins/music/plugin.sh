#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 21.02.2009
#
# vdr-music

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

[ -f ./../../vdr/patchlevel.conf ] && source ./../../vdr/patchlevel.conf

WEB="http://www.vdr.glaserei-franz.de/files/vdr-music-0.9.3-testing.tgz"
#WEB="http://www.glaserei-franz.de/VDR/Moronimo2/files/vdr-music-0.4.0-b3.tgz"
VERSION="music-0.9.3-testing"
LINK="music"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  [ "$mp3" != "on" ] && rm -f $VDRLIBDIR/libvdr-mplayer.so*
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
  [ "$VDRUPDATE" = "on" ] && [ -d $VDRCONFDIR/plugins/music ] && return

  if [ ! -d $VDRCONFDIR/plugins/music ] && [ -d $SOURCEDIR/VDR/PLUGINS/src/$LINK/music ]; then
    cp -rf $SOURCEDIR/VDR/PLUGINS/src/$LINK/music $VDRCONFDIR/plugins
  fi

  # mp3sources.conf
  if [ -f $DIR/musicsources.conf ]; then
    cp -f $DIR/musicsources.conf $VDRCONFDIR/plugins/music
  else
    {
      echo "$MUSICDIR;Locale Platte;0;*.mp3/*.ogg/*.wav"
      echo "/media/usb;USB-Stick;1;*.mp3/*.ogg/*.wav"
      echo "/media/cdrom;CDROM;1;*.mp3/*.ogg/*.wav"
      echo "/media/cdfs;CD-Audio;1;*.wav"
      echo ""
    } > $VDRCONFDIR/plugins/music/musicsources.conf
  fi
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/music

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

  # mplayer.sh
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
