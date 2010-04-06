#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 04.02.2007

# kernel-update

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

[ "$LINUXVERSION" = "debian" ] || exit 2

SOURCEDIR="/usr/src"

kernel="$(wget -O - http://www.kernel.org/kdist/finger_banner | awk '/latest stable version/ {printf("%s",$NF);}')"
WEB="http://www.kernel.org/pub/linux/kernel/v2.6/linux-${kernel}.tar.bz2"
VERSION="linux-${kernel}"
LINK="linux"

VAR=`basename $WEB`
DIR=`pwd`

# install
function make_util() {

  apt_install "build-essential libncurses5-dev dpkg-dev gcc g++ libc6-dev make patch debhelper bzip2 kernel-package sudo cdbs quilt patchutils yaird dh-buildinfo xmlto cramfsprogs"


  # download und symlink
  download_util
  extract_util

  cd $SOURCEDIR
  rm -f $LINK
  ln -vfs $VERSION $LINK

  # install
  cd $SOURCEDIR/$LINK

  # eigene config kopieren
  [ -f "$DIR/.config" ] && cp -f $DIR/.config $SOURCEDIR/$LINK

  # search for *.diff
  for i in `ls $DIR/patches | grep ".diff$"`; do
    log "apply $i"
    patch -p 1 < $DIR/patches/$i
  done

  # einfach mit exit wieder raus und speichern
  make menuconfig
  ## kernel bauen
  # aenderungen an der .config vorgenommen wurden (make-kphg clean).
  make-kpkg kernel_image --revision=dvb.0
  # make-kpkg kernel_image kernel_headers kernel_source kernel_doc --revision=dvb.0 --initrd
  # installieren
  dpkg -i ../linux-image-$kernel\_dvb.0_i386.deb

  # test
  if [ -d "$SOURCEDIR/$VERSION" ]; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
  fi
}

# uninstall
function clean_util() {
  cd $SOURCEDIR/$LINK
  make uninstall

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
