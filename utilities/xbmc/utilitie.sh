#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 18.07.2009 -Integration von XBMC und VDR - Karsten Wacker

# xbmc-svn

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

#WEB="ffmpeg-svn"
VERSION="XBMC"
LINK="xbmc"

#VAR=`basename $WEB`
DIR=`pwd`

DATE=`date +%Y%m%d`

# install
function make_util() {
  # pre install
    apt_remove "xbmc"


  if [ "$LINUXVERSION" = "ubuntu" ]; then
    apt_install "build-essential debhelper quilt python-support cmake autotools-dev autoconf automake unzip libboost-dev libgl1-mesa-dev libglu-dev libglew-dev libmad0-dev libjpeg-dev libsamplerate-dev libogg-dev libvorbis-dev libfreetype6-dev libfontconfig-dev libbz2-dev libfribidi-dev libsqlite3-dev libmysqlclient-dev libasound-dev libpng-dev libpcre3-dev liblzo2-dev libcdio-dev libsdl-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libenca-dev libjasper-dev libxt-dev libxmu-dev libxinerama-dev libcurl4-gnutls-dev libdbus-1-dev libhal-storage-dev libhal-dev libpulse-dev libavahi-common-dev libavahi-client-dev libxrandr-dev libavcodec-dev libavformat-dev libavutil-dev libpostproc-dev libswscale-dev liba52-dev libdts-dev libfaad-dev libmp4ff-dev libmpeg2-4-dev libass-dev libmpcdec-dev libflac-dev libwavpack-dev python-dev gawk gperf nasm libcwiid1-dev libbluetooth-dev libsmbclient-dev libmicrohttpd-dev libmodplug-dev"
  else
    apt_install "build-essential debhelper quilt python-support cmake autotools-dev autoconf automake unzip libboost-dev libgl1-mesa-dev libglu-dev libglew-dev libmad0-dev libjpeg-dev libsamplerate-dev libogg-dev libvorbis-dev libfreetype6-dev libfontconfig-dev libbz2-dev libfribidi-dev libsqlite3-dev libmysqlclient-dev libasound-dev libpng-dev libpcre3-dev liblzo2-dev libcdio-dev libsdl-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libenca-dev libjasper-dev libxt-dev libxmu-dev libxinerama-dev libcurl4-gnutls-dev libdbus-1-dev libhal-storage-dev libhal-dev libpulse-dev libavahi-common-dev libavahi-client-dev libxrandr-dev libavcodec-dev libavformat-dev libavutil-dev libpostproc-dev libswscale-dev liba52-dev libdts-dev libfaad-dev libmp4v2-dev libmpeg2-4-dev libass-dev libmpcdec-dev libflac-dev libwavpack-dev python-dev gawk gperf nasm libcwiid1-dev libbluetooth-dev libmicrohttpd-dev libmodplug-dev"
  fi

  # download_util
  cd $SOURCEDIR
  if [ -d $VERSION ]; then
    cd $VERSION 
    svn update 
    make distclean
    ./bootstrap
  else
    svn checkout http://xbmc.svn.sourceforge.net/svnroot/xbmc/branches/pvr-testing2/ XBMC
  cd $SOURCEDIR  
  cd $Version
    ./bootstrap
  fi

  # setzen des symlinks
  cd $SOURCEDIR
  rm -f $LINK
  ln -vfs $VERSION $LINK

  cd $SOURCEDIR/$LINK

  # install
  ./configure --enable-goom &&
  make -j2 && checkinstall --fstrans=no --install=yes --pkgname=xbmc --pkgversion "${DATE}-xvdr" --default && TEST=ok

  # test
  if [ "$TEST" != "ok" ]; then
    log "ERROR - $VERSION konnte nicht erstellt werden"
    return 1
  fi

  # save deb file
  [ -d "$DIR/packages" ] || mkdir -p $DIR/packages
  cp -f xbmc*.deb $DIR/packages

}


# start

# plugin commands
if [ $# \> 0 ]; then
  cmd=$1
  cmd_util
else
  make_util
fi

exit 0
