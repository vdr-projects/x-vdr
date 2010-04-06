#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 08.03.2009

# mplayer

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

snapshot=`date '+%F'`

WEB="http://www.mplayerhq.hu/MPlayer/releases/mplayer-checkout-snapshot.tar.bz2"
VERSION="mplayer-checkout-$snapshot"
LINK="mplayer"

VAR=`basename $WEB`
DIR=`pwd`

DATE=`date +%Y%m%d`

# install
function make_util() {
  status=`status_util`
  if [ "$status" != "0" ]; then
    apt_remove "$(apt-cache search mplayer | cut -d" " -f1 | grep mplayer)"
    apt_remove "$(apt-cache search mencoder | cut -d" " -f1 | grep mencoder)"
  fi

  # download and extract snapshot
  path_to_snapshot="$DIR/../../files/utilities"
  if [ ! -f $path_to_snapshot/mplayer-checkout-$snapshot.tar.bz2 ]; then
    download_util
    mkdir -p /tmp/mplayer-checkout-$snapshot
    tar xjfv $path_to_snapshot/mplayer-checkout-snapshot.tar.bz2  -C /tmp/mplayer-checkout-$snapshot
    VERSION="$(ls /tmp/mplayer-checkout-$snapshot)"
    VAR="${VERSION}.tar.bz2"
    mv -f $path_to_snapshot/mplayer-checkout-snapshot.tar.bz2 $path_to_snapshot/$VAR
    rm -rf /tmp/mplayer-checkout-$snapshot
  else
    log "mplayer-checkout-$snapshot.tar.bz2 gefunden"
    VAR="mplayer-checkout-$snapshot.tar.bz2"
  fi

  extract_util

  # setzen des symlinks
  cd $SOURCEDIR
  rm -f $LINK
  ln -vfs $VERSION $LINK

  # mplayer
  cd $SOURCEDIR/$LINK

  if [ -d $SOURCEDIR/DVB/linux/include/linux/dvb ]; then # v4l-dvb or multiproto are installed
    ./configure --prefix=$PREFIX --enable-dvb --enable-dvbhead --with-extraincdir=$SOURCEDIR/DVB/linux/include \
                --language=de,en --enable-gui --enable-largefiles --enable-menu --win32codecsdir=/usr/lib/win32
  else
    ./configure --prefix=$PREFIX  --enable-dvb --enable-dvbhead \
                --language=de,en --enable-gui --enable-largefiles --enable-menu --win32codecsdir=/usr/lib/win32
  fi

  make && checkinstall --fstrans=no --install=yes --pkgname=mplayer --pkgversion "2:1.0.svn${DATE}-xvdr" --default

  # test
  TEST=`which mplayer`
  if [ "$TEST" ] ; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
    return 1
  fi

  # save deb file
  [ -d "$DIR/packages" ] || mkdir -p $DIR/packages
  cp -f mplayer*.deb $DIR/packages

  # create mencoder dummy package
  cd $DIR/packages
  echo "Section: misc
Priority: optional
Standards-Version: 3.6.2

Package: mencoder
Version: 2:1.0svn${DATE}-xvdr-1
Maintainer: Musterman <Musterman@musterman.de>
Depends: mplayer
Provides: mplayer
Architecture: all
Description: Dummy-mencoder
" > ./mencoder

  equivs-build mencoder
  dpkg -i mencoder_1.0svn${DATE}-xvdr-1_all.deb

  ldconfig

  # mplayer font
  cd $DIR
  WEB="\
ftp://ftp.fu-berlin.de/unix/X11/multimedia/MPlayer/releases/fonts/font-arial-iso-8859-1.tar.bz2
http://www1.mplayerhq.hu/MPlayer/releases/fonts/font-arial-iso-8859-1.tar.bz2"
  VAR=`basename $WEB`
  if [ -f "$FILES/utilities/$VAR" ]; then
    log "$VAR gefunden"
  elif [ -f "$VAR" ]; then
    log "$VAR gefunden"
    cp "$VAR" "$FILES/utilities"
  else
    log "$VAR nicht gefunden"
    log "Starte download"
    for i in $WEB; do
      wget --tries=2 "$i" --directory-prefix="$FILES/utilities" && log "Download von $VAR erfolgreich" && break
    done
    [ ! -f "$FILES/utilities/$VAR" ] && log "Download von $VAR nicht erfolgreich"
  fi
  if [ -f "$FILES/utilities/$VAR" ]; then
    [ ! -d $PREFIX/share/mplayer/font ] && mkdir -p $PREFIX/share/mplayer/font
    tar xjfv "$FILES/utilities/$VAR" -C $DIR
    cp $DIR/font-arial-iso-8859-1/font-arial-18-iso-8859-1/* $PREFIX/share/mplayer/font/
  else
    log "Installation von $VAR nicht erfolgreich"
  fi

  # mplayer skin
  cd $DIR
  WEB="\
ftp://ftp.fu-berlin.de/unix/X11/multimedia/MPlayer/skins/Blue-1.7.tar.bz2
http://www.mplayerhq.hu/MPlayer/skins/Blue-1.7.tar.bz2"
  VAR=`basename $WEB`
  if [ -f "$FILES/utilities/$VAR" ]; then
    log "$VAR gefunden"
  elif [ -f "$VAR" ]; then
    log "$VAR gefunden"
    cp "$VAR" "$FILES/utilities"
  else
    log "$VAR nicht gefunden"
    log "Starte download"
    for i in $WEB; do
      wget --tries=2 "$i" --directory-prefix="$FILES/utilities" && log "Download von $VAR erfolgreich" && break
    done
    [ ! -f "$FILES/utilities/$VAR" ] && log "Download von $VAR nicht erfolgreich"
  fi

  if [ -f "$FILES/utilities/$VAR" ]; then
    [ ! -d $PREFIX/share/mplayer/skins ] && mkdir -p $PREFIX/share/mplayer/skins
    tar xjfv "$FILES/utilities/$VAR" -C $PREFIX/share/mplayer/skins/
    cd $PREFIX/share/mplayer/skins/
    ln -sf Blue default
  else
    log "Installation von $VAR nicht erfolgreich"
  fi

  # mplayer.sh
  cd $DIR
  WEB="http://batleth.sapienti-sat.org/projects/VDR/versions/mplayer.sh-0.8.7.tar.gz"
  VAR=`basename $WEB`
  if [ -f mplayer.sh ] && [ -f mplayer.sh.conf ]; then
    cp mplayer.sh mplayer.sh.conf $VDRSCRIPTDIR
  else
    if [ -f "$FILES/utilities/$VAR" ]; then
      log "$VAR gefunden"
    elif [ -f "$VAR" ]; then
      log "$VAR gefunden"
      cp "$VAR" "$FILES/utilities"
    else
      log "$VAR nicht gefunden"
      log "Starte download"
      for i in $WEB; do
        wget --tries=2 "$i" --directory-prefix="$FILES/utilities" && log "Download von $VAR erfolgreich" && break
      done
      [ ! -f "$FILES/utilities/$VAR" ] && log "Download von $VAR nicht erfolgreich"
    fi
    if [ -f "$FILES/utilities/$VAR" ]; then
      tar xjfv "$FILES/utilities/$VAR" -C $DIR
      cp mplayer.sh mplayer.sh.conf $VDRSCRIPTDIR
    else
      log "Installation von $VAR nicht erfolgreich"
    fi
  fi

  if [ -f $VDRSCRIPTDIR/mplayer.sh ] && [ -f $VDRSCRIPTDIR/mplayer.sh.conf ] ; then
    chown $VDRUSER.$VDRGROUP $VDRSCRIPTDIR/mplayer.sh $VDRSCRIPTDIR/mplayer.sh.conf
    chmod 0744 $VDRSCRIPTDIR/mplayer.sh
  fi

  # mkdir DVD-VCD
  if [ ! -d $MEDIADIR/DVD-VCD ] ; then
    mkdir -p $MEDIADIR/DVD-VCD
    touch $MEDIADIR/DVD-VCD/DVD $MEDIADIR/DVD-VCD/VCD
    chmod 0666 $MEDIADIR/DVD-VCD/DVD $MEDIADIR/DVD-VCD/VCD
    chown -R $VDRUSER:$VDRGROUP $MEDIADIR/DVD-VCD
  fi

  # mkdir divx verzeichnis erstellen
  [ ! -d $DIVXDIR ] && mkdir -p $DIVXDIR && log "Erstelle $DIVXDIR"
}

# uninstall
function clean_util() {
  # remove files
  rm -f $VDRSCRIPTDIR/mplayer.sh
  rm -f $VDRSCRIPTDIR/mplayer.sh.conf
  rm -rf $PREFIX/share/mplayer

  # uninstall
  apt_remove "mplayer"
  apt_remove "mencoder"

  # remove source
  cd $SOURCEDIR
  [ -L "$LINK" ] && rm -rf "$LINK"
  [ -d "$VERSION" ] && rm -rf "$VERSION"
#  rm -rf mplayer-checkout-*

  ldconfig
}

# test
function status_util() {
  TEST=`which mplayer`
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
