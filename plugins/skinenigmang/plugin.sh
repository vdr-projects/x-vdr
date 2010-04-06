#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 22.03.2009
#
# vdr-skinenigmang

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/vdr-skinenigmang/vdr-skinenigmang-0.1.0pre.tgz"
VERSION="skinenigmang-0.1.0pre"
LINK="skinenigmang"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -f $VDRLIBDIR/libvdr-$LINK*
  rm -rf $VDRCONFDIR/plugins/skinenigmang
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

  if [ "$avards" != "on" ] && [ -f "$DIR/do_not_use_avards.diff" ]; then
    cd "$SOURCEDIR/VDR/PLUGINS/src/$LINK"
    echo "apply patch do_not_use_avards.diff"
    patch < $DIR/do_not_use_avards.diff
  fi

  if [ "$epgsearch" != "on" ] && [ -f "$DIR/do_not_use_epgsearch.diff" ]; then
    cd "$SOURCEDIR/VDR/PLUGINS/src/$LINK"
    echo "apply patch do_not_use_epgsearch.diff"
    patch < $DIR/do_not_use_epgsearch.diff
  fi

  if [ "$mailbox" != "on" ] && [ -f "$DIR/do_not_use_mailbox.diff" ]; then
    cd "$SOURCEDIR/VDR/PLUGINS/src/$LINK"
    echo "apply patch do_not_use_mailbox.diff"
    patch < $DIR/do_not_use_mailbox.diff
  fi

  # logos and themes
  cd $DIR
   if [ "$dxr3" = "on" ]; then
    local WEB="http://andreas.vdr-developer.org/enigmang/download/skinenigmang-channellogos-xpm-lo-20070702.tgz"
  else
    local WEB="http://andreas.vdr-developer.org/enigmang/download/skinenigmang-channellogos-xpm-hi-20070702.tgz"
  fi
  local VAR=`basename $WEB`
  download_plugin
  if echo "$FILES/plugins/$VAR" | grep "bz2$" - &>/dev/null; then
    if tar xjf "$FILES/plugins/$VAR" -C $VDRCONFDIR/plugins; then log "extrahiere $VAR" ; fi
  else
    if tar xzf "$FILES/plugins/$VAR" -C $VDRCONFDIR/plugins; then log "extrahiere $VAR" ; fi
  fi

  if [ "$dxr3" = "on" ]; then
    local WEB="http://andreas.vdr-developer.org/enigmang/download/skinenigmang-logos-xpm-lo-20070702.tgz"
  else
    local WEB="http://andreas.vdr-developer.org/enigmang/download/skinenigmang-logos-xpm-hi-20070702.tgz"
  fi
  local VAR=`basename $WEB`
  download_plugin
  if echo "$FILES/plugins/$VAR" | grep "bz2$" - &>/dev/null; then
    if tar xjf "$FILES/plugins/$VAR" -C $VDRCONFDIR/plugins; then log "extrahiere $VAR" ; fi
  else
    if tar xzf "$FILES/plugins/$VAR" -C $VDRCONFDIR/plugins; then log "extrahiere $VAR" ; fi
  fi

  cp -f $SOURCEDIR/VDR/PLUGINS/src/$LINK/themes/*.theme $VDRCONFDIR/themes
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/skinenigmang $VDRCONFDIR/themes
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
