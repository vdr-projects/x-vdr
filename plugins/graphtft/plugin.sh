#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 23.03.2009
#
# vdr-graphtft

# defaults
source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

#WEB="http://www.jwendel.de/vdr/vdr-graphtft-0.3.3.tar.bz2"
WEB="http://www.zulu-entertainment.de/files/vdr-graphtft/vdr-graphtft-0.3.3-rev24.tar.bz2"
VERSION="graphtft-0.3.3"
LINK="graphtft"

VAR=`basename $WEB`
DIR=`pwd`

# plugin entfernen
function clean_plugin() {
  cd $SOURCEDIR/VDR/PLUGINS/src
  rm -rf $LINK*
  rm -rf $VDRCONFDIR/plugins/graphTFT/themes/DeepBlue
  rm -rf $VDRCONFDIR/plugins/graphTFT/themes/alien-vs-predator
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
  patch_p1_plugin

  ## plugin specials - start ##
  # themes
  [ ! -d $VDRCONFDIR/plugins/graphTFT/fonts ] && mkdir -p $VDRCONFDIR/plugins/graphTFT/fonts
  [ ! -d $VDRCONFDIR/plugins/graphTFT/themes ] && mkdir -p $VDRCONFDIR/plugins/graphTFT/themes

  if [ ! -f $VDRCONFDIR/plugins/graphTFT/fonts/Vera.ttf ]; then
    if [ -f $DIR/Vera.ttf ]; then
      cp -f $DIR/Vera.ttf $VDRCONFDIR/plugins/graphTFT/fonts
    elif [ -f /usr/share/fonts/truetype/ttf-bitstream-vera/Vera.ttf ]; then
      cp -f /usr/share/fonts/truetype/ttf-bitstream-vera/Vera.ttf $VDRCONFDIR/plugins/graphTFT/fonts
    fi
  fi

  if [ ! -f $VDRCONFDIR/plugins/graphTFT/fonts/Enigma.ttf ]; then
    if [ -f $DIR/Enigma.ttf ]; then
      cp -f $DIR/Enigma.ttf $VDRCONFDIR/plugins/graphTFT/fonts
    elif [ -f $VDRCONFDIR/plugins/graphTFT/fonts/Vera.ttf ]; then
      cd $VDRCONFDIR/plugins/graphTFT/fonts
      ln -vfs Vera.ttf Enigma.ttf
    fi
  fi

  cd $DIR

  # themes
  local WEB="http://www.jwendel.de/vdr/DeepBlue-horchi-0.3.1.tar.bz2"
  local VAR=`basename $WEB`
  download_plugin
  if echo "$FILES/plugins/$VAR" | grep "bz2$" - &>/dev/null; then
    if tar xjf "$FILES/plugins/$VAR" -C $VDRCONFDIR/plugins/graphTFT/themes; then log "extrahiere $VAR" ; fi
  else
    if tar xzf "$FILES/plugins/$VAR" -C $VDRCONFDIR/plugins/graphTFT/themes; then log "extrahiere $VAR" ; fi
  fi

  local WEB="http://www.jwendel.de/vdr/alien-vs-predator-0.3.1.tar.bz2"
  local VAR=`basename $WEB`
  download_plugin
  if echo "$FILES/plugins/$VAR" | grep "bz2$" - &>/dev/null; then
    if tar xjf "$FILES/plugins/$VAR" -C $VDRCONFDIR/plugins/graphTFT/themes; then log "extrahiere $VAR" ; fi
  else
    if tar xzf "$FILES/plugins/$VAR" -C $VDRCONFDIR/plugins/graphTFT/themes; then log "extrahiere $VAR" ; fi
  fi

  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/plugins/graphTFT
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
