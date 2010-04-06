#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 24.01.2009

# LCDproc - LCD Daemon und Module

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://dfn.dl.sourceforge.net/sourceforge/lcdproc/lcdproc-0.5.2.tar.gz"
VERSION="lcdproc-0.5.2"
LINK="lcdproc"
VAR=`basename $WEB`
DIR=`pwd`

# install
function make_util() {
  # pre install
  status=`status_util`
  if [ "$status" != "0" ]; then
    apt_remove "lcdproc"
  fi
  download_util
  extract_util

  # setzen des symlinks
  cd $SOURCEDIR
  rm -f $LINK
  ln -vfs $VERSION $LINK

  # LCDproc
  cd $SOURCEDIR/$LINK
  ./configure --prefix=$PREFIX --enable-drivers=all
  make && checkinstall --fstrans=no --install=yes --pkgname=lcdproc --pkgversion "0.5.2-xvdr" --default

  # test
  TEST=`which LCDd`
  if [ "$TEST" ]; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
    return 1
  fi

  # save deb file
  [ -d "$DIR/packages" ] || mkdir -p $DIR/packages
  cp -f lcdproc*.deb $DIR/packages

  if [ -f $DIR/LCDd.conf ]; then
    cp -f $DIR/LCDd.conf /etc
  else
    cp -f LCDd.conf /etc
  fi

  # autostart LCDd
  cp -f $DIR/lcdd /etc/init.d
  chmod 0755 /etc/init.d/lcdd
  unfreeze_rc
  update-rc.d lcdd defaults 20
  freeze_rc

  ldconfig

}

# uninstall
function clean_util() {
  apt_remove "lcdproc"

  # remove source
  cd $SOURCEDIR
  [ -L "$LINK" ] && rm -rf "$LINK"
  [ -d "$VERSION" ] && rm -rf "$VERSION"

  rm -f /etc/LCDd.conf
  unfreeze_rc
  update-rc.d -f lcdd remove
  freeze_rc
  rm -f /etc/init.d/lcdd

  ldconfig
}

# test
function status_util() {
  TEST=`which LCDd`
  if [ "$TEST" ]; then
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
