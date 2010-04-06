#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 27.07.2006

# vdrsync

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdrsync.vdr-portal.de/releases/vdrsync-050322.tgz"
VERSION="vdrsync-050322"
LINK="vdrsync"

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
  cp -f vdrsync.pl /usr/bin
  chmod 0755 /usr/bin/vdrsync.pl

  ldconfig

  # test
  TEST=`which vdrsync.pl`
  if [ "$TEST" ]; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
  fi
}

# uninstall
function clean_util() {
  # remove script
  rm -f /usr/bin/vdrsync.pl

  # remove source
  cd $SOURCEDIR
  rm -rf $LINK
  rm -rf $VERSION

  ldconfig
}

# test
function status_util() {
  TEST=`which vdrsync.pl`
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
