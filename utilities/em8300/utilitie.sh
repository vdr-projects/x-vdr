#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 25.11.2007

# em8300 - module fuer dxr3

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/em8300/em8300-cvs20071122.tar.bz2"
VERSION="em8300-cvs20071122"
LINK="em8300"
CVS="2"

if [ "$CVS" = "1" ]; then
  VERSION="em8300-cvs"
fi

KERNEL=`uname -r`
EM8300="/lib/modules/$KERNEL/em8300"
VAR=`basename $WEB`
DIR=`pwd`

function make_util() {
  if [ "$CVS" = "1" ]; then
    [ ! -d "$DIR/em8300-cvs" ] && mkdir -p $DIR/em8300-cvs
    cd $DIR/em8300-cvs
    echo "CVS password: [Just press enter]"
    cvs -d:pserver:anonymous@dxr3.cvs.sourceforge.net:/cvsroot/dxr3 login
    cvs -z3 -d:pserver:anonymous@dxr3.cvs.sourceforge.net:/cvsroot/dxr3 co -P em8300
    [ -d "$DIR/em8300-cvs/em8300" ] || return 1
    [ -d "$SOURCEDIR/$VERSION" ] && rm -rf "$SOURCEDIR/$VERSION"
    cp -R em8300 $SOURCEDIR/$VERSION
    [ -d "$SOURCEDIR/$VERSION" ] || return 1
  else
    download_util
    extract_util
  fi

  cd $SOURCEDIR
  rm -f $LINK
  ln -vfs $VERSION $LINK

  # install tools
  cd $SOURCEDIR/$LINK
  [ "$CVS" != "0" ] && ./bootstrap
  ./configure --prefix=$PREFIX
  make
  make install

  # install modules
  cd $SOURCEDIR/$LINK/modules
  make
  make install
  # copy microcode
  cp em8300.uc /usr/share/misc
  # make devices
  #./devices.sh

  # Scripte kopieren
  cp -f $DIR/ldm $VDRSCRIPTDIR
  chmod 0744 $VDRSCRIPTDIR/ldm

  cp -f $DIR/rmm $VDRSCRIPTDIR
  chmod 0744 $VDRSCRIPTDIR/rmm
  chown $VDRUSER:$VDRGROUP $VDRSCRIPTDIR/ldm $VDRSCRIPTDIR/rmm

  ldconfig

  if [ -f $DIR/em8300 ]; then
    cp -f $DIR/em8300 /etc/modprobe.d
  elif [ -x /usr/sbin/dxr3config ]; then
    dxr3config
  fi

  if [ -f /etc/modprobe.d/em8300 ] && [ `grep -cw '^options em8300 .*audio_driver=oss' /etc/modprobe.d/em8300` -eq 0 ]; then
    em8300_options=`grep -m 1 '^options em8300'`
    if [ -n "$em8300_options" ]; then
      sed -i /etc/modprobe.d/em8300 -e s/"$em8300_options"/"$em8300_options audio_driver=oss"/g
    else
      echo "options em8300 audio_driver=oss" >> /etc/modprobe.d/em8300
    fi
  elif [ ! -f /etc/modprobe.d/em8300 ]; then
    echo "options em8300 audio_driver=oss" > /etc/modprobe.d/em8300
  fi

  depmod

  # test
  if [ -f $EM8300/adv717x.ko ] && [ -f $EM8300/bt865.ko ] && [ -f $EM8300/em8300.ko ]; then
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
  fi
# Module laden
#cd $VDRSCRIPTDIR
#./rmm
#./ldm
#em8300setup
}

# uninstall
function clean_util() {
  # uninstall
  if [ -d $SOURCEDIR/em8300 ]; then
    cd $SOURCEDIR/em8300
    make uninstall
    cd $SOURCEDIR
    rm -rf em8300*
  else
    # remove source
    cd $SOURCEDIR
    rm -rf em8300*
  fi

  # remove modules
  rm -rf $EM8300

  # remove microcode
  rm -f /usr/share/misc/em8300.uc

  # remove scripts
  rm -f $VDRSCRIPTDIR/ldm
  rm -f $VDRSCRIPTDIR/rmm



  ldconfig
}

# test
function status_util() {
  if [ -f $EM8300/adv717x.ko ] && [ -f $EM8300/bt865.ko ] && [ -f $EM8300/em8300.ko ]; then
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
