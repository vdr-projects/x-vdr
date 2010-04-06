#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 20.12.2007
#
# vdr-music

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

[ -f ./../../vdr/patchlevel.conf ] && source ./../../vdr/patchlevel.conf

WEB="http://www.vdr.glaserei-franz.de/files/moron-suite-0.0.2.tar.bz2"
VERSION="music-0.2.0"
LINK="music"
VAR_music="vdr-music-0.2.0.tar.gz"

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

  if [ ! -f "$FILES/plugins/$VAR_music" ] && [ -f "$FILES/plugins/$VAR" ]; then
    [ -d "$FILES/plugins/moron" ] && rm -rf $FILES/plugins/moron
    tar xjf "$FILES/plugins/$VAR" -C "$FILES/plugins"
    mv -f $FILES/plugins/moron/vdr-*.tar.gz $FILES/plugins
    [ -d "$FILES/plugins/moron" ] && rm -rf $FILES/plugins/moron
  fi
  VAR="$VAR_music"

  extract_plugin
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -f $LINK
  ln -vfs $VERSION $LINK

  patch_plugin

  ## plugin specials - start ##
  # wareagle-icons
#  if [ "${VDRVERSION:2:1}" = "4" ]; then
  if [ "$WAREAGLEICON" = "on" ]; then
    cd "$SOURCEDIR/VDR/PLUGINS/src/$LINK"
    echo "apply patch have_iconpatch.diff"
    patch < $DIR/have_iconpatch.diff
  fi

  # mplayer
  if [ "$mp3" != "on" ]; then
    cd "$SOURCEDIR/VDR/PLUGINS/src/$LINK"
    echo "apply patch with_mplayer.diff"
    patch < $DIR/with_mplayer.diff
  fi

  # music - config, scripts and themes
  cp -fR $SOURCEDIR/VDR/PLUGINS/src/$LINK/music $VDRCONFDIR/plugins
  rm -f $VDRCONFDIR/plugins/music/themes/*-DEEP3*.theme
  rm -f $VDRCONFDIR/plugins/music/themes/osd-ENIGMANG*.theme

  cp -f $DIR/getcover.pl $VDRCONFDIR/plugins/music/downloads/music_cover
  cp -f $DIR/musiccmds.dat $VDRCONFDIR/plugins/music/data
  cp -f $DIR/scripts/* $VDRCONFDIR/plugins/music/scripts
  cp -f $DIR/themes/* $VDRCONFDIR/plugins/music/themes


  chmod 0744 $VDRCONFDIR/plugins/music/scripts/*
  chmod 0744 $VDRCONFDIR/plugins/music/downloads/music_cover/getcover.pl

  # mp3sources.conf
  if [ -f $DIR/musicsources.conf ]; then
    cp -f $DIR/musicsources.conf $VDRCONFDIR/plugins/music
  else
    {
      echo "$MUSICDIR;Locale Platte;0;*.mp3/*.ogg/*.wav"
      echo "/media/cdrom0;CDROM;1"
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
