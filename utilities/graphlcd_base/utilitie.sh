#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 23.06.2008

# graphlcd-base - module fuer graphlcd

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://download.berlios.de/graphlcd/graphlcd-base-0.1.5.tgz"
VERSION="graphlcd-base-0.1.5"
LINK="graphlcd-base"
VAR=`basename $WEB`
DIR=`pwd`

# Make.config fuer graphlcd
function make_makeconfig() {
MAKECONFIG="$SOURCEDIR/$LINK/Make.config"

if [ -f $MAKECONFIG ] ; then
  cp $MAKECONFIG $MAKECONFIG.old
  rm -f $MAKECONFIG
fi

echo "#
# User defined Makefile options for graphlcd daemon and tools

### The C compiler and options:

CC       = gcc
CFLAGS   = -O2

CXX      = g++
CXXFLAGS = -g -O2 -Wall -Woverloaded-virtual
#CXXFLAGS = -g -ggdb -O0 -Wall -Woverloaded-virtual

#LDFLAGS  = -g -ggdb -O0

LDCONFIG = ldconfig

### The directory environment:

BINDIR = $PREFIX/bin
LIBDIR = $PREFIX/lib
INCDIR = $PREFIX/include
MANDIR = $PREFIX/man

### Includes and defines

#INCLUDES += -I

DEFINES += -D_GNU_SOURCE

HAVE_FREETYPE2=1" >> $MAKECONFIG
}

# install
function make_util() {
  download_util
  extract_util

  # setzen des symlinks
  cd $SOURCEDIR
  rm -f $LINK
  ln -vfs $VERSION $LINK

  make_makeconfig

  patch -p0 < $DIR/graphlcd-base-0.1.5-gcc43.patch

  # graphlcd-base
  cd $SOURCEDIR/$LINK
  make all
  make install

  if [ -f $DIR/graphlcd.conf ] ; then 
    cp -f $DIR/graphlcd.conf /etc
  else
    cp -f graphlcd.conf /etc
  fi

  ldconfig

  # test
  if [ -f /usr/lib/libglcddrivers.so ]; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
  fi
}

# uninstall
function clean_util() {
  cd $SOURCEDIR/$LINK
  make uninstall
  make clean

  # remove source
  cd $SOURCEDIR
  rm -rf $LINK
  rm -rf $VERSION

  ldconfig
}

# test
function status_util() {
  if [ -f /usr/lib/libglcddrivers.so ]; then
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
