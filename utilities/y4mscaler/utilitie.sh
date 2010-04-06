#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 23.10.2006

# y4mscaler

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.mir.com/DMG/Software/y4mscaler-9.0-src.tgz"
VERSION="y4mscaler-9.0"
LINK="y4mscaler"

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

  # y4mscaler
  cd $SOURCEDIR/$LINK
  make
  cp -f ./y4mscaler /usr/bin 

  ldconfig

  # test
  TEST=`which y4mscaler`
  if [ "$TEST" ]; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
  fi
}

# uninstall
function clean_util() {
  # remove bin
  bin=`which y4mscaler`
  rm -f $bin

  # remove source
  cd $SOURCEDIR
  rm -rf $LINK
  rm -rf $VERSION

  ldconfig
}

# test
function status_util() {
  TEST=`which y4mscaler`
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
