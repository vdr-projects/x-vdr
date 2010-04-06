#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 02.03.2009

# libdvdread

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

#WEB="libdvdread-svn"
VERSION="libdvdread-svn"
LINK="libdvdread"

#VAR=`basename $WEB`
DIR=`pwd`

# install
function make_util() {
  # pre install
  status=`status_util`
  if [ "$status" != "0" ]; then
    apt_remove "$(apt-cache search libdvdread | cut -d" " -f1 | grep libdvdread | grep -v libdvdread3)"
  fi

  # download_util
  cd $SOURCEDIR
  [ -d $VERSION ] || svn checkout svn://svn.mplayerhq.hu/dvdnav/trunk/libdvdread $VERSION
  [ ! -d $VERSION ] && echo "1" && exit 1

  # setzen des symlinks
  cd $SOURCEDIR
  rm -f $LINK
  ln -vfs $VERSION $LINK

  # install
  cd $SOURCEDIR/$LINK
  ./configure2 --prefix=$PREFIX --enable-static=no
  make && checkinstall --fstrans=no --install=yes --pkgname=libdvdread4 --pkgversion "4.1.2-3-xvdr" --default && TEST=ok

  # test
  if [ "$TEST" != "ok" ]; then
    log "ERROR - $VERSION konnte nicht erstellt werden"
    return 1
  fi
  log "SUCCESS - $VERSION erstellt"

  # save deb file
  [ -d "$DIR/packages" ] || mkdir -p $DIR/packages
  cp -f libdvdread*.deb $DIR/packages

  ldconfig
}

# uninstall
function clean_util() {
  apt_remove "$(apt-cache search libdvdread | cut -d" " -f1 | grep libdvdread | grep -v libdvdread3)"

  # remove source
  cd $SOURCEDIR
  [ -L "$LINK" ] && rm -rf "$LINK"
  [ -d "$VERSION" ] && rm -rf "$VERSION"

  ldconfig
}

# test
function status_util() {
  LIBS="$(apt-cache search libdvdread | cut -d" " -f1 | grep libdvdread)"
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
