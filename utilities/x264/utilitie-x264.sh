#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 03.03.2009

# x264

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

DIR=`pwd`
DATE=`date +%Y%m%d`

# install
function make_util() {
  # pre install
  status=`status_util`
  if [ "$status" != "0" ]; then
    apt_remove "$(apt-cache search "libx264" | grep "libx264" | cut -d" " -f1)"
    apt_remove "x264"
  fi
  # make & checkinstall
  cd $SOURCEDIR
  git clone git://git.videolan.org/x264.git
  cd x264
  ./configure --prefix=$PREFIX --enable-shared
  make && checkinstall --fstrans=no --install=yes --pkgname=x264 --pkgversion "1:0.svn${DATE}-xvdr" --default && TEST=ok

  # test
  if [ "$TEST" != "ok" ]; then
    log "ERROR - x264 konnte nicht erstellt werden"
    return 1
  fi

  # save deb file
  [ -d "$DIR/packages" ] || mkdir -p $DIR/packages
  cp -f x264*.deb $DIR/packages

  # create dummy packages
  VERSNUM=$(ls $SOURCEDIR/x264 | grep "libx264.so" | cut -f3 -d".")
  cd $DIR/packages
  echo "Section: misc
Priority: optional
Standards-Version: 3.6.2

Package: libx264-${VERSNUM}
Version: 1:0.svn${DATE}-xvdr-1
Maintainer: Musterman <Musterman@musterman.de>
Depends: x264
Provides: x264
Architecture: all
Description: Dummy-libx264-${VERSNUM}
" > ./libx264-${VERSNUM}

  equivs-build libx264-${VERSNUM}
  dpkg -i libx264-${VERSNUM}_0.svn${DATE}-xvdr-1_all.deb

  echo "Section: misc
Priority: optional
Standards-Version: 3.6.2

Package: libx264-dev
Version: 1:0.svn${DATE}-xvdr-1
Maintainer: Musterman <Musterman@musterman.de>
Depends: x264
Provides: x264
Architecture: all
Description: Dummy-libx264-dev
" > ./libx264-dev

  equivs-build libx264-dev
  dpkg -i libx264-dev_0.svn${DATE}-xvdr-1_all.deb

  ldconfig
  log "SUCCESS - x264 erstellt"
}

# uninstall
function clean_util() {
  apt_remove "$(apt-cache search "libx264" | grep "libx264" | cut -d" " -f1)"
  apt_remove "x264"

  # remove source
  cd $SOURCEDIR
  [ -d x264 ] && rm -rf x264

  ldconfig
}

# test
function status_util() {
  LIBS="x264 $(apt-cache search "libx264" | grep "libx264" | cut -d" " -f1)"
  for package in $LIBS; do
    TEST=`apt_installed $package`
    if [ "$TEST" = "xvdr" ]; then
      [ -d $SOURCEDIR/x264 ] && echo "2" && return 0
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
