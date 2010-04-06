#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 02.03.2009

# vidix

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://dfn.dl.sourceforge.net/vidix/vidix-1.0.0.tar.bz2"
VERSION="vidix-1.0.0"
LINK="vidix"

VAR=`basename $WEB`
DIR=`pwd`

# install
function make_util() {
  # pre install
  status=`status_util`
  if [ "$status" != "0" ]; then
    apt_remove "vidix"
  fi
  download_util
  extract_util

  # setzen des symlinks
  cd $SOURCEDIR
  rm -f $LINK
  ln -vfs $VERSION $LINK

  # install
  cd $SOURCEDIR/$LINK
  ./configure --prefix=$PREFIX
  make && checkinstall --fstrans=no --install=yes --pkgname=vidix --pkgversion "1.0.0-xvdr" --default && TEST=ok

#  cd $PREFIX/lib
#  [ -f libdha.so ] && ln -vfs libdha.so.1.0.0 libdha.so

  # test
  if [ "$TEST" = "ok" ] && [ -f $PREFIX/include/vidix/fourcc.h ] && [ -f $PREFIX/include/vidix/vidix.h ] && [ -f $PREFIX/include/vidix/vidixlib.h ]; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
    return
  fi

  # save deb file
  [ -d "$DIR/packages" ] || mkdir -p $DIR/packages
  cp -f vidix*.deb $DIR/packages

  ldconfig
}

# uninstall
function clean_util() {
  apt_remove "vidix"

  # remove source
  cd $SOURCEDIR
  [ -L "$LINK" ] && rm -rf "$LINK"
  [ -d "$VERSION" ] && rm -rf "$VERSION"

  ldconfig
}

# test
function status_util() {
  LIBS="$(apt-cache search vidix | cut -d" " -f1 | grep vidix)"
  for package in $LIBS; do
    TEST=`apt_installed $package`
    if [ "$TEST" = "xvdr" ]; then
      [ -d $SOURCEDIR/$LINK ] && echo "2" && return 0
      echo "1" && return 0
    elif [ "$TEST" = "debian" ]; then
      echo "3" && return 0
    fi
  done
  echo "0"
}

# test
function status_util() {
  if [ -f $PREFIX/include/vidix/fourcc.h ] && [ -f $PREFIX/include/vidix/vidix.h ] && [ -f $PREFIX/include/vidix/vidixlib.h ]; then
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
