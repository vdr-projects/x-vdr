#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 23.03.2009

# tcmplex-panteltje

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://ip51cf87c4.direct-adsl.nl/panteltje/dvd/tcmplex-panteltje-0.4.7.tgz"
VERSION="tcmplex-panteltje-0.4.7"
LINK="tcmplex-panteltje"

VAR=`basename $WEB`
DIR=`pwd`

# install
function make_util() {
  download_util
  extract_util

  # setzen des symlinks
  cd $SOURCEDIR
  rm -f $LINK
  ln -vfs $VERSION $LINK

  # install
  cd $SOURCEDIR/$LINK
  make
  cp -f tcmplex-panteltje $PREFIX/bin

  ldconfig

  # test
  TEST=`which tcmplex-panteltje`
  if [ "$TEST" ]; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
  fi
}

# uninstall
function clean_util() {
  # remove bin
  rm -f $PREFIX/bin/tcmplex-panteltje

  # remove source
  cd $SOURCEDIR
  rm -rf $LINK
  rm -rf $VERSION

  ldconfig
}

# test
function status_util() {
  TEST=`which tcmplex-panteltje`
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
