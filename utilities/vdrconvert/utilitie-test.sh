#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 05.05.2008

# vdrconvert

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdr-wiki.de/vdr/vdrconvert/vdrconvert-0.2.1.tar.gz"
#VERSION="vdrconvert-0.2.1"
LINK="vdrconvert"

VAR=`basename $WEB`
DIR=`pwd`

VDRCONVERTDIR="$(dirname $VDRSCRIPTDIR)/vdrconvert"

# install
function make_util() {
  apt_install "recode mpg321 cdparanoia vcdimager vorbis-tools cdrdao"
#  apt_install "mjpegtools transcode"

  download_util
  extract_util

  # setzen des symlinks
  cd $SOURCEDIR
  rm -f $LINK
#  ln -vfs $VERSION $LINK

  # install
  mkdir -p /var/log/vdrconvert
  mkdir -p /var/run/vdrconvert
  mkdir -p /var/spool/vdrconvert
  chown -R $VDRUSER:$VDRGROUP /var/log/vdrconvert /var/run/vdrconvert /var/spool/vdrconvert

  mkdir -p $VDRCONVERTDIR/share
  cp -rf $SOURCEDIR/$LINK/share/vdrconvert/* $VDRCONVERTDIR/share
  cp -rf $SOURCEDIR/$LINK/bin $VDRCONVERTDIR
  chown -R $VDRUSER:$VDRGROUP $VDRCONVERTDIR
  chmod -R 0744 $VDRCONVERTDIR

  cp -f $DIR/vdrconvert /etc/init.d
  chmod 0755 /etc/init.d/vdrconvert
#  freeze_rc
#  update-rc.d vdrconvert defaults 93
#  unfreeze_rc

  [ ! -d "$VDRCONFDIR/.vdrconvert" ] && mkdir -p "$VDRCONFDIR/.vdrconvert"
  cp -f $DIR/vdrconvert.env $VDRCONFDIR/.vdrconvert
  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR/.vdrconvert
#	    $DIR/commands
#	    $DIR/reccmds

  # tosvcd installieren
#  WEB="http://vdr-wiki.de/vdr/tosvcd/tosvcd-0.9.tar.bz2"
#  VERSION="tosvcd-0.9"
#  LINK="tosvcd"
#  VAR=`basename $WEB`
#  download_util
#  extract_util

#  cd $SOURCEDIR
#  rm -f $LINK
#  ln -vfs $VERSION

#  cd $LINK
#  make
#  cp -f tosvcd $PREFIX/bin

  # tcmplex-panteltje installieren
  WEB="http://panteltje.com/panteltje/dvd/tcmplex-panteltje-0.4.7.tgz"
  VERSION="tcmplex-panteltje-0.4.7"
  LINK="tcmplex-panteltje"
  VAR=`basename $WEB`
  download_util
  extract_util

  cd $SOURCEDIR
  rm -f $LINK
  ln -vfs $VERSION

  cd $LINK
  make
  cp -f tcmplex-panteltje $PREFIX/bin
  ln -vfs $PREFIX/bin/tcmplex-panteltje $PREFIX/bin/tcmplex

  # test
  if [ -f $SOURCEDIR/vdrconvert/install.sh ]; then
    log "SUCCESS - vdrconvert-0.2.1 erstellt"
  else
    log "ERROR - vdrconvert-0.2.1 konnte nicht erstellt werden"
  fi
}

# uninstall
function clean_util() {
  rm -rf /var/log/vdrconvert
  rm -rf /var/run/vdrconvert
  rm -rf /var/spool/vdrconvert
  rm -rf "$VDRCONFDIR/.vdrconvert"
  CONVERTDIR="$(dirname $VDRCONVERTDIR)"
  [ "$CONVERTDIR" = "vdrconvert" ] && rm -rf "$VDRCONVERTDIR"
  rm -f /etc/init.d/vdrconvert

  # remove source
  cd $SOURCEDIR
  rm -rf $LINK

  # tcmplex-panteltje entfernen
  rm -rf tcmplex-panteltje
  rm -rf tcmplex-panteltje-0.4.7
  rm -f $PREFIX/bin/tcmplex
  rm -f $PREFIX/bin/tcmplex-panteltje
}

# test
function status_util() {
  if [ -f $SOURCEDIR/$LINK/install.sh ]; then
    [ -d $SOURCEDIR/$LINK ] && echo "2" && return 0
    echo "1"
  else
    echo "0"
  fi
}

# start

# plugin commands
if [ $# \> 0 ]; then
  cmd=$1
  cmd_util
else
  make_util
  status_util
fi

exit 0
