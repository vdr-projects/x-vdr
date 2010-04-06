#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 02.03.2009

# noad

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdr-wiki.de/vdr/noad/noad-0.6.1.tar.bz2"
VERSION="noad-0.6.1"
LINK="noad"

VAR=`basename $WEB`
DIR=`pwd`

# install
function make_util() {
  # pre install
  status=`status_util`
  if [ "$status" != "0" ]; then
    apt_remove "noad"
  fi

  download_util
  extract_util

  # setzen des symlinks
  cd $SOURCEDIR
  rm -f $LINK
  ln -vfs $VERSION $LINK

  # install
  cd $SOURCEDIR/$LINK

  [ -f "$DIR/noad_0.6.1_all-patches.diff" ] && patch -p0 < $DIR/noad_0.6.1_all-patches.diff

  ./configure --prefix=$PREFIX \
              --with-ffmpeg \
              --with-ffmpeglibdir=$PREFIX/lib \
              --with-ffmpeginclude=$PREFIX/include/libavcodec \
              --with-mpeginclude=$PREFIX/include/mpeg2dec


  make && checkinstall --fstrans=no --install=yes --pkgname=noad --pkgversion "0.6.1-xvdr" --default

  # test
  TEST=`which noad`
  if [ "$TEST" ]; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
    return 1
  fi

  # save deb file
  [ -d "$DIR/packages" ] || mkdir -p $DIR/packages
  cp -f noad*.deb $DIR/packages

  ldconfig

}

# uninstall
function clean_util() {
  # uninstall noad
  apt_remove "noad"

  # remove source
  cd $SOURCEDIR
  [ -L "$LINK" ] && rm -rf "$LINK"
  [ -d "$VERSION" ] && rm -rf "$VERSION"

  ldconfig
}

# test
function status_util() {
  TEST=`which noad`
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
