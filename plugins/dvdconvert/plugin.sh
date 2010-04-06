#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 23.03.2009
#
# vdr-dvdconvert

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdr-wiki.de/vdr/vdr-dvdconvert/vdr-dvdconvert-1.0.2.tar.bz2"
VERSION="dvdconvert-1.0.2"
LINK="dvdconvert"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  log "cleaning $LINK"
  [ "$VDRUPDATE" = "on" ] && return
  rm -r $VDRSCRIPTDIR/dvdconvert
  rm -f $VDRCONFDIR/plugins/dvdconvert.conf
  rm -f $VDRCONFDIR/plugins/dvdconvert.conf.save
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
  # dirs
  mkdir -p $VDRVARDIR/dvdconvert/dvd2vdr
  mkdir -p $VDRVARDIR/dvdconvert/dvd2dvd
  mkdir -p $VDRVARDIR/dvdconvert/log
  chown -R $VDRUSER:$VDRGROUP $VDRVARDIR/dvdconvert

  # scripts
  [ "$VDRUPDATE" = "on" ] && [ -d $VDRSCRIPTDIR/dvdconvert ] && return
  if [ -d $DIR/dvdconvert ]; then
    cp -r $DIR/dvdconvert $VDRSCRIPTDIR/
    chown -R $VDRUSER:$VDRGROUP $VDRSCRIPTDIR/dvdconvert
    chmod 0744 $VDRSCRIPTDIR/dvdconvert/*
  fi

  # config
echo "# This file contains the tasks for the dvdconvert plugin
# Syntax:
# <script>:<name>:<value>:<type>:<length>:<choices>:<description>:
#
:dvd2vdr
--- Einstellungen_dvd2vdr ---
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:ACTION:0:L:1:all,copy,demux,encode,mplex,split,move:Actions:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:LANGUAGE:0:L:1:de,en:Language:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:OSDINFO:1:B:0:Nein,Ja:OSD-Info:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:TITLE: :A:15:abcdefghijklmnopqrstuvwxyz0123456789-_ABCDEFGHIJKLMNOPQRSTUVWXYZ:Title (optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:TITLENUM: :A:3:0,99,MAX,AUTO:Specific title (00-99) or (MAX = max. Frames) or (AUTO = vobcopy-test)(optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:ACTION_DEMUX:0:L:0:tcextract,projectX:Demuxer:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:WITHOUT_X:0:B:1:Nein,Ja:Start Xvfb (optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:A52DEC_GAIN:00:I:2:-96,96:Audio gain (-96.0 to +96.0)(optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:ACTION_ENCODE:0:L:0:toolame,mp2enc:Encoder:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:ACTION_MPLEX:0:L:0:mplex,tcmplex,tcmplex-panteltje:Remuxer:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:ACTION_GENINDEX:1:L:0:genindex-mjpegfix,genindex:Write index.vdr:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:REMOVE:1:B:1:Nein,Ja:Remove tmp files:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:CLEAN:0:B:1:Nein,Ja:Clean dirs:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:VERBOSE:1:B:1:Nein,Ja:Turns verbosity on:
:
---
#
---
:dvd2dvd
--- Einstellungen_dvd2dvd ---
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:ACTION1:0:L:1:all,copy,demux,encode,reqant,mplex,dvdauthor,iso,move:Actions:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:LANGUAGE1:0:L:1:de,en:Language:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:OSDINFO1:1:B:0:Nein,Ja:OSD-Info:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:TITLE1: :A:15:abcdefghijklmnopqrstuvwxyz0123456789-_ABCDEFGHIJKLMNOPQRSTUVWXYZ:Title (optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:TITLENUM1: :A:3:0,99,MAX,AUTO:Specific title (00-99) or (MAX = max. Frames) or (AUTO = vobcopy-test)(optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:ACTION_DEMUX1:0:L:0:tcextract,projectX:Demuxer:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:WITHOUT_X1:0:B:1:Nein,Ja:Start Xvfb (optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:A52DEC_GAIN1:00:I:2:-96,96:Audio gain (-96.0 to +96.0)(optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:ACTION_ENCODE1:0:L:0:toolame,mp2enc:Encoder:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:ACTION_MPLEX1:1:L:0:mplex,tcmplex,tcmplex-panteltje:Remuxer:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:BURN1:1:B:1:Nein,Ja:Burn DVD:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:RW_FORMAT1:0:B:1:Nein,Ja:Format DVD-RW:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:REMOVE_ISO1:0:B:1:Nein,Ja:Remove this iso file:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:REMOVE1:0:B:1:Nein,Ja:Remove tmp files:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:CLEAN1:0:B:1:Nein,Ja:Clean dirs:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:VERBOSE1:1:B:1:Nein,Ja:Turns verbosity on:
" > $VDRCONFDIR/plugins/dvdconvert.conf


echo "# This file contains the tasks for the dvdconvert plugin
# Syntax:
# <script>:<name>:<value>:<type>:<length>:<choices>:<description>:
#
:dvd2vdr
--- Einstellungen_dvd2vdr ---
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:ACTION:0:L:1:all,copy,demux,encode,mplex,split,move:Actions:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:LANGUAGE:0:L:1:de,en:Language:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:OSDINFO:1:B:0:Nein,Ja:OSD-Info:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:TITLE: :A:15:abcdefghijklmnopqrstuvwxyz0123456789-_ABCDEFGHIJKLMNOPQRSTUVWXYZ:Title (optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:TITLENUM: :A:3:0,99,MAX,AUTO:Specific title (00-99) or (MAX = max. Frames) or (AUTO = vobcopy-test)(optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:ACTION_DEMUX:0:L:0:tcextract,projectX:Demuxer:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:WITHOUT_X:0:B:1:Nein,Ja:Start Xvfb (optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:A52DEC_GAIN: :I:2:-96,96:Audio gain (-96.0 to +96.0)(optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:ACTION_ENCODE:0:L:0:toolame,mp2enc:Encoder:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:ACTION_MPLEX:0:L:0:mplex,tcmplex,tcmplex-panteltje:Remuxer:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:ACTION_GENINDEX:0:L:0:genindex-mjpegfix,genindex:Write index.vdr:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:REMOVE:0:B:1:Nein,Ja:Remove tmp files:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:CLEAN:0:B:1:Nein,Ja:Clean dirs:
$VDRSCRIPTDIR/dvdconvert/start_dvd2vdr.sh:VERBOSE:1:B:1:Nein,Ja:Turns verbosity on:
:
---
#
---
:dvd2dvd
--- Einstellungen_dvd2dvd ---
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:ACTION1:0:L:1:all,copy,demux,encode,reqant,mplex,dvdauthor,iso,move:Actions:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:LANGUAGE1:0:L:1:de,en:Language:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:OSDINFO1:1:B:0:Nein,Ja:OSD-Info:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:TITLE1: :A:15:abcdefghijklmnopqrstuvwxyz0123456789-_ABCDEFGHIJKLMNOPQRSTUVWXYZ:Title (optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:TITLENUM1: :A:3:0,99,MAX,AUTO:Specific title (00-99) or (MAX = max. Frames) or (AUTO = vobcopy-test)(optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:ACTION_DEMUX1:0:L:0:tcextract,projectX:Demuxer:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:WITHOUT_X1:0:B:1:Nein,Ja:Start Xvfb (optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:A52DEC_GAIN1: :I:2:-96,96:Audio gain (-96.0 to +96.0)(optional):
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:ACTION_ENCODE1:0:L:0:toolame,mp2enc:Encoder:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:ACTION_MPLEX1:1:L:0:mplex,tcmplex,tcmplex-panteltje:Remuxer:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:BURN1:1:B:1:Nein,Ja:Burn DVD:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:RW_FORMAT1:0:B:1:Nein,Ja:Format DVD-RW:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:REMOVE_ISO1:0:B:1:Nein,Ja:Remove this iso file:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:REMOVE1:0:B:1:Nein,Ja:Remove tmp files:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:CLEAN1:0:B:1:Nein,Ja:Clean dirs:
$VDRSCRIPTDIR/dvdconvert/start_dvd2dvd.sh:VERBOSE1:1:B:1:Nein,Ja:Turns verbosity on:
" > $VDRCONFDIR/plugins/dvdconvert.conf.save

  chown $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/dvdconvert.conf $VDRCONFDIR/plugins/dvdconvert.conf.save

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
