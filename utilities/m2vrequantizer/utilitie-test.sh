#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 27.07.2006

# M2VRequantizer (requant)

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.xeatre.tv/community/burn/contrib/M2VRequantizer.tar.gz"
VERSION="M2VRequantizer"
LINK="m2vrequantizer"

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
#  gcc -o requant main.c -lm
  cp requant /usr/bin

  ldconfig

  # test
  TEST=`which genindex`
  if [ "$TEST" ]; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
  fi
}

# uninstall
function clean_util() {
  # remove bin
  rm -f /usr/bin/requant

  # remove source
  cd $SOURCEDIR
  rm -rf $LINK
  rm -rf $VERSION

  ldconfig
}

# test
function status_util() {
  TEST=`which requant`
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
