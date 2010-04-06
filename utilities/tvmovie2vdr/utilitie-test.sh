#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 05.05.2008

# tvmovie2vdr

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://vdr-wiki.de/vdr/tvmovie2vdr/tvmovie2vdr-0.5.13.tar.gz"
VERSION="tvmovie2vdr-0.5.13"
#LINK="tvmovie2vdr"

VAR=`basename $WEB`
DIR=`pwd`

TVMDIR="$(dirname $VDRSCRIPTDIR)/tvmovie2vdr"

# install
function make_util() {
  apt_install "libdate-manip-perl perlmagick"

  download_util
  extract_util

  # install
  cd $SOURCEDIR/$VERSION
  mv -f config.pl_dist config.pl
  mv -f channels.pl_dist channels.pl
  mv -f channels_wanted.pl_dist channels_wanted.pl
  cp -f $DIR/scripts/* .
  mv -f $SOURCEDIR/$VERSION $TVMDIR
  chown -R $VDRUSER:$VDRGROUP $TVMDIR

#  WEB="http://www.cpan.org/modules/by-module/LWP/GBARR/IO-1.2301.tar.gz"
#  VAR=`basename $WEB`
#  download_util
#  extract_util
#  cd $SOURCEDIR/IO-1.2301
#  perl Makefile.PL
#  make
#  make install

  # test
  if [ -f $TVMDIR/tvm2vdr.pl ]; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
  fi
}

# uninstall
function clean_util() {
  rm -rf $TVMDIR
}

# test
function status_util() {
  if [ -f $TVMDIR/tvm2vdr.pl ]; then
    echo "2"
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
