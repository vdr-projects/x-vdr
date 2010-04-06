#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 12.04.2009

# xine-lib und xine-ui

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions
DIR=`pwd`

# xine-lib
WEB="http://home.vrweb.de/~rnissl/xine-lib-cvs-20090412200000.tar.bz2"
VERSION="xine-lib-cvs-20090412200000"
LINK="xine-lib"
PKGVERSION="1.1.cvs200904122-xvdr"

# hg_clone = xine_lib_vers -1
case "$xine_lib_vers" in
  2) HG_CLONE=1;;
  3) HG_CLONE=2;;
  *) HG_CLONE=0;;
esac

# zum ueberschreiben von xine_lib_vers
# xine aus dem hg HG_CLONE=1, und mit vdpau-patch HG_CLONE=2
#HG_CLONE=2

# wenn ffmpeg aus dem svn kommt nehmen wir xine aus dem hg
[ "$ffmpeg" = "on" -a "$HG_CLONE" = "0" ] && HG_CLONE=1

if [ "$HG_CLONE" != "0" ]; then
  VERSION="xine-lib-1.2"
  PKGVERSION="1.2.hg`date +%Y%m%d`-xvdr"
fi

# xine-ui
WEB_UI="http://home.vrweb.de/~rnissl/xine-ui-cvs-20090412200000.tar.bz2"
VERSION_UI="xine-ui-cvs-20090412200000"
LINK_UI="xine-ui"

# dummys
DUMMY_LIBS="libxine1-bin libxine1-ffmpeg libxine1-x libxine-dev"

# install
function make_util() {
  # pre-install
  status=`status_util`
  [ "$status" != "0" ] && apt_remove "xine-ui libxine-dev $(apt-cache search "libxine1" | cut -d" " -f1)"
  # x264
  if [ "$ffmpeg" = "on" ]; then
    if [ "`apt_installed x264`" != "xvdr" ]; then
      cd $DIR/../x264
      chmod 744 utilitie-x264.sh
      ./utilitie-x264.sh || {
        log "WARNING - xine-lib konnte x264 nicht finden"
#        return 1
        }
    fi
  else
    apt_install "libx264-dev"
  fi

  # xine-lib
  if [ "$HG_CLONE" = "0" ]; then
    VAR=`basename $WEB`
    download_util
    extract_util
  else
    cd $SOURCEDIR
    log "Starte download von $VERSION"
    hg clone http://hg.debian.org/hg/xine-lib/$VERSION || {
      log "ERROR - $VERSION konnte nicht geladen werden"
      return 1
      }
    # symlink
    rm -rf $LINK
    ln -vfs $VERSION $LINK
  fi

  log "Starte mit $VERSION"
  cd $SOURCEDIR/$LINK

  # patches
  if [ "$HG_CLONE" = "0" ]; then
    # this patch is for the xine-plugin
    [ -f $DIR/patches/xine-lib.patch ] && patch -p1 < $DIR/patches/xine-lib.patch
    # this patch is for external ffmpeg
    [ -f $DIR/patches/xine-lib-ffmpeg.diff ] && patch -p1 < $DIR/patches/xine-lib-ffmpeg.diff

  elif [ "$HG_CLONE" = "2" ]; then
    lattest_patch=xine-lib-1.2-vdpau-r247.diff.bz2    
    if wget --tries=2 http://www.jusst.de/vdpau/files/xine-lib-1.2/ --directory-prefix="$DIR" && [ -f $DIR/index.html ]; then
      lattest_patch=$(grep  "xine-lib-1.2-vdpau-.*.diff.bz2" $DIR/index.html | tail -1 | cut -d '=' -f4 | cut -d '"' -f2)
      rm  -f $DIR/index.html
      [ -f $DIR/patches/$lattest_patch  ] || wget --tries=2 http://www.jusst.de/vdpau/files/xine-lib-1.2/$lattest_patch --directory-prefix="$DIR/patches"
    fi
    if [ -f $DIR/patches/$lattest_patch ]; then
      if bzcat $DIR/patches/$lattest_patch | patch -p1 --dry-run ; then
        bzcat $DIR/patches/$lattest_patch | patch -p1
        PKGVERSION="1.2.hg-vdpau`date +%Y%m%d`-xvdr"
      fi
    fi
  fi

  # ffmpeg

  # make xine-lib
  AUTOGEN=""
  [ "$ffmpeg" = "on" ] && AUTOGEN="$AUTOGEN --with-external-ffmpeg"
  ./autogen.sh --prefix=$PREFIX $AUTOGEN
  make && checkinstall --fstrans=no --install=yes --pkgname=libxine1 --pkgversion "$PKGVERSION" --default && TEST=ok

  # test
  if [ "$TEST" != "ok" ]; then
    log "ERROR - $VERSION konnte nicht erstellt werden"
    return 1
  fi

  # save deb file
  [ -d "$DIR/packages" ] || mkdir -p $DIR/packages
  cp -f libxine*.deb $DIR/packages

  # dummys
  cd $DIR/packages
  for package in $DUMMY_LIBS; do
    echo "Section: misc
Priority: optional
Standards-Version: 3.6.2

Package: $package
Version: $PKGVERSION-1
Maintainer: Musterman <Musterman@musterman.de>
Depends: xine
Provides: xine
Architecture: all
Description: Dummy-$package
" > ./$package

    equivs-build $package
    dpkg -i ${package}_${PKGVERSION}-1_all.deb

  done

  ldconfig

  # xine-ui
  WEB="$WEB_UI"
  VAR=`basename $WEB`
  download_util
  extract_util
  # symlink
  cd $SOURCEDIR
#  rm -rf $LINK_UI
#  ln -vfs $VERSION_UI $LINK_UI

  log "Starte mit $LINK_UI"
  cd $SOURCEDIR/$LINK_UI

  # make xine-ui
  ./autogen.sh --prefix=$PREFIX --enable-vdr-keys
  make && checkinstall --fstrans=no --install=yes --pkgname=xine-ui --pkgversion "0.99.6.cvs20090112-xvdr" --default && TEST=ok

  # test
  if [ "$TEST" != "ok" ]; then
    log "ERROR - $VERSION_UI konnte nicht erstellt werden"
    return 1
  fi

  ldconfig

  # final test
  TEST=`which xine`
  if [ "$TEST" ]; then
    log "SUCCESS - $VERSION_UI erstellt"
  else
    log "ERROR - $VERSION_UI konnte nicht erstellt werden"
  fi
}

# uninstall
function clean_util() {
  # uninstall
  for package in $DUMMY_LIBS; do
    apt_remove "$package"
  done
  apt_remove "xine-ui libxine-dev $(apt-cache search "libxine1" | cut -d" " -f1)"

  # remove source
  cd $SOURCEDIR
  [ -d "$LINK_UI" ]    && rm -rf "$LINK_UI"
  [ -d "$VERSION_UI" ] && rm -rf "$VERSION_UI"
  [ -L "$LINK" ]       && rm -rf "$LINK"
  [ -d "$VERSION" ]    && rm -rf "$VERSION"

  ldconfig
}

# test
function status_util() {
  TEST=`apt_installed libxine1`
  if [ "$TEST" = "xvdr" ]; then
    [ -d $SOURCEDIR/xine-lib ] && echo "2" && return 0
    echo "1"
  elif [ "$TEST" = "debian" ]; then
    echo "3"
  else
    echo "0"
  fi
}

# plugin commands
if [ $# \> 0 ]; then
  cmd=$1
  cmd_util
else
  make_util
  status_util
fi

exit 0
