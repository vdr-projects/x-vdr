#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 09.02.2009

# liplianindvb

source ./../../../x-vdr.conf
source ./../../../setup.conf
source ./../../../functions


VERSION="liplianindvb"
WEB="http://mercurial.intuxication.org/hg/$VERSION"
LINK="DVB"

DIR=`pwd`

# install
function make_util() {

  apt-get update
  apt_install "mercurial"
  apt_install "linux-headers-`uname -r`"
  [ -L /usr/src/linux ] && rm -f /usr/src/linux
  if [ ! -d /usr/src/linux ]; then
    cd /usr/src
    ln -vfs /usr/src/linux-headers-`uname -r` linux
  fi

  # download und symlink
  cd $SOURCEDIR
  hg clone $WEB

  rm -f $LINK
  ln -vfs $VERSION $LINK

  cd $SOURCEDIR/$LINK/linux/include/linux
  if [ -f /usr/src/linux/include/linux/compiler.h ]; then
    ln -s /usr/src/linux/include/linux/compiler.h compiler.h
  elif [ -f /usr/src/$(uname -r)/include/linux/compiler.h ]; then
    ln -s /usr/src/$(uname -r)/include/linux/compiler.h compiler.h
  elif [ -f /usr/src/linux-headers-$(uname -r)/include/linux/compiler.h ]; then
    ln -s /usr/src/linux-headers-$(uname -r)/include/linux/compiler.h compiler.h
  else
    log "ERROR - /usr/src/linux/include/linux/compiler.h nicht gefunden"
  fi

  # install
  cd $SOURCEDIR/$LINK

  # search for *.diff
  for i in `ls $DIR/patches | grep ".diff$"`; do
    log "apply $i"
    patch -p 1 < $DIR/patches/$i
  done

  make menuconfig
  make
  if [ $? = 0 ] ; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
    return 1
  fi

  dialog --title " x-vdr - $VERSION " --yesno "Die DVB-Treiber wurden in $SOURCEDIR/$VERSION erstellt. \nSollen sie jetzt installiert werden?" 19 70
  [ $? = 0 ] || return 0
  make install && cp -rf $SOURCEDIR/$VERSION/linux/include/linux/dvb /usr/include/linux && log "SUCCESS - $VERSION installiert"
}

# uninstall
function clean_util() {
  # remove source
  cd $SOURCEDIR
  rm -rf $LINK
  rm -rf $VERSION
}

# test
function status_util() {
  if [ -d "$SOURCEDIR/$VERSION" ]; then
    [ -d "$SOURCEDIR/$VERSION" ] && echo "2" && return 0
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
