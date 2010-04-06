#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 30.03.2009

# ffmpeg-svn

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

#WEB="ffmpeg-svn"
VERSION="ffmpeg-svn"
LINK="ffmpeg"

#VAR=`basename $WEB`
DIR=`pwd`

DATE=`date +%Y%m%d`
DUMMY_LIBS="libavcodec51 libavcodec52 libavdevice52 libavfilter0 libavformat52 libavutil49 libpostproc51 libswscale0"

LIBS="$(apt-cache search "libavcodec"  | grep "libavcodec"  | cut -d" " -f1) \
      $(apt-cache search "libavdevice" | grep "libavdevice" | cut -d" " -f1) \
      $(apt-cache search "libavfilter" | grep "libavfilter" | cut -d" " -f1) \
      $(apt-cache search "libavformat" | grep "libavformat" | cut -d" " -f1) \
      $(apt-cache search "libavutil"   | grep "libavutil"   | cut -d" " -f1) \
      $(apt-cache search "libpostproc" | grep "libpostproc" | cut -d" " -f1) \
      $(apt-cache search "libswscale"  | grep "libswscale"  | cut -d" " -f1)"

# install
function make_util() {
  # pre install
  status=`status_util`
  if [ "$status" != "0" ]; then
    apt_remove "ffmpeg $LIBS"
    [ -d /usr/include/ffmpeg ] && rm -rf /usr/include/ffmpeg
  fi

  apt_install "libgsm1-dev"
  if [ "$LINUXVERSION" = "ubuntu" ]; then
    apt_install "libvorbis-perl libogg-vorbis-decoder-perl"
  else
    apt_install "libogg-vorbis-perl"
  fi

  # x264
  if [ "`apt_installed x264`" != "xvdr" ]; then
    cd $DIR/../x264
    chmod 744 utilitie-x264.sh
    ./utilitie-x264.sh || {
      log "ERROR - ffmpeg konnte x264 nicht finden"
      return 1
      }
  fi

  # download_util
  cd $SOURCEDIR
  [ -d $VERSION ] || svn checkout svn://svn.mplayerhq.hu/ffmpeg/trunk $VERSION
  [ ! -d $VERSION ] && echo "1" && exit 1

  # setzen des symlinks
  cd $SOURCEDIR
  rm -f $LINK
  ln -vfs $VERSION $LINK

  cd $SOURCEDIR/$LINK

  # check options
  all_options=$(./configure --help)
  checked_options=""
  my_options="--enable-shared --enable-pthreads --enable-postproc --enable-avfilter --enable-avfilter-lavf \
              --enable-gpl --enable-x11grab --enable-libfaac --enable-libfaad --enable-libgsm --enable-libmp3lame \
              --enable-libtheora --enable-libvorbis --enable-libx264 --enable-libxvid"

  for option in $my_options; do
    echo "$all_options" | grep "\\$option" >null && checked_options="$checked_options $option"
  done

  # install
  ./configure --prefix=$PREFIX $checked_options &&
  make && checkinstall --fstrans=no --install=yes --pkgname=ffmpeg --pkgversion "4:0.5.svn${DATE}-xvdr" --default && TEST=ok

  # test
  if [ "$TEST" != "ok" ]; then
    log "ERROR - $VERSION konnte nicht erstellt werden"
    return 1
  fi

  # save deb file
  [ -d "$DIR/packages" ] || mkdir -p $DIR/packages
  cp -f ffmpeg*.deb $DIR/packages

  # dummys
  cd $DIR/packages

  for package in $DUMMY_LIBS; do
    echo "Section: misc
Priority: optional
Standards-Version: 3.6.2

Package: $package
Version: 4:0.5.svn${DATE}-xvdr-1
Maintainer: Musterman <Musterman@musterman.de>
Depends: ffmpeg
Provides: ffmpeg
Architecture: all
Description: Dummy-$package
" > ./$package

    equivs-build $package
    dpkg -i ${package}_0.5.svn${DATE}-xvdr-1_all.deb

  done
  # we need libavcodec51 for vlc
  cd $PREFIX/lib
  ln -vfs libavcodec.so libavcodec.so.51

  log "SUCCESS - $VERSION erstellt"
  ldconfig
}

# uninstall
function clean_util() {
  for package in ffmpeg $DUMMY_LIBS; do
    apt_remove "$package"
  done

  [ -d "$PREFIX/include/ffmpeg" ] && rm -rf "$PREFIX/include/ffmpeg"

  # remove source
  cd $SOURCEDIR
  [ -L "$LINK" ] && rm -rf "$LINK"
  [ -d "$VERSION" ] && rm -rf "$VERSION"

  ldconfig
}

# test
function status_util() {
  LIBTEST=""
  for package in ffmpeg $LIBS; do
    TEST=`apt_installed $package`
    [ "$TEST" = "debian" ] && LIBTEST="debian"
    [ "$TEST" = "xvdr" ] && LIBTEST="xvdr" && break
  done

  if [ "$LIBTEST" = "xvdr" ]; then
    [ -d $SOURCEDIR/$LINK ] && echo "2" && return 0
    echo "1"
  elif [ "$LIBTEST" = "debian" ]; then
    echo "3"
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
