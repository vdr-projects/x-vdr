#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 17.03.2009

# lirc

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

# uncomment to reset LINUXVERSION
#LINUXVERSION=

# if you got into trouble, try again with a newer version like
# http://www.lirc.org/software/snapshots/lirc-0.8.5pre1.tar.bz2

WEB="http://prdownloads.sourceforge.net/lirc/lirc-0.8.4a.tar.bz2"
VERSION="lirc-0.8.4a"
LINK="lirc"

VAR=`basename $WEB`
DIR=`pwd`

KERNEL=`uname -r`
LIRC_MODULES="/lib/modules/$KERNEL/misc"
[ "$LINUXVERSION" = "sidux" ] && LIRC_MODULES="/lib/modules/$KERNEL/extra/lirc-modules"
LIRC_DRIVER="serial"
AUTOSERIAL="/var/lib/setserial/autoserial.conf"
MODPROBE="/etc/modprobe.d/lirc"
if [ "$lirc_port" = "2" ]; then
  LIRC_PORT="0x2f8"
  LIRC_IRQ="3"
  SERIAL="/dev/ttyS1"
else
  LIRC_PORT="0x3f8"
  LIRC_IRQ="4"
  SERIAL="/dev/ttyS0"
fi

# make
function make_util() {
  if [ "$LINUXVERSION" != "sidux" ]; then
    # pre install
    if [ "`apt_installed lirc`" != "xvdr" ]; then
      apt_remove "lirc $(apt-cache search liblircclient | cut -d" " -f1 | grep liblircclient)"
    fi

    # download and untar
    download_util
    extract_util

    # symlink
    cd $SOURCEDIR
    rm -f $LINK
    ln -vfs $VERSION $LINK

    # install
    WITH_LIRC_DRIVER=
    for i in $LIRC_DRIVER; do
      WITH_LIRC_DRIVER="$WITH_LIRC_DRIVER --with-driver=$i"
    done
    if [ ! "$WITH_LIRC_DRIVER" ]; then
      LIRC_DRIVER="serial"
      WITH_LIRC_DRIVER="--with-driver=serial"
    fi

    cd $SOURCEDIR/$LINK
    ./configure --prefix=$PREFIX $WITH_LIRC_DRIVER --with-port=$LIRC_PORT --with-irq=$LIRC_IRQ --enable-debug
    make && checkinstall --fstrans=no --install=yes --pkgname=lirc --pkgversion "0.8.4a-xvdr" --default  && TEST=ok

    # test
    if [ "$TEST" != "ok" ]; then
      log "ERROR - $VERSION konnte nicht erstellt werden"
      return 1
    fi

    # save deb file
    [ -d "$DIR/packages" ] || mkdir -p $DIR/packages
    cp -f lirc*.deb $DIR/packages

    # dummy
    cd $DIR/packages
    echo "Section: misc
Priority: optional
Standards-Version: 3.6.2

Package: liblircclient0
Version: 0.8.4a-xvdr-1
Maintainer: Musterman <Musterman@musterman.de>
Depends: ffmpeg
Provides: ffmpeg
Architecture: all
Description: Dummy-liblircclient0
" > ./liblircclient0

    equivs-build liblircclient0
    dpkg -i liblircclient0_0.8.4a-xvdr-1_all.deb

    ldconfig
  fi

  # config
  TEST=`which lircd`
  if [ "$TEST" ] && [ -f $LIRC_MODULES/lirc_dev.ko ]; then
    # lirc_serial
    if [ -f $LIRC_MODULES/lirc_serial.ko ]; then
      setserial $SERIAL uart none
      echo "#KERNEL" > /var/lib/setserial/autoserial.conf
      echo "$SERIAL uart none" >> /var/lib/setserial/autoserial.conf
      echo "" >> /var/lib/setserial/autoserial.conf

      echo "alias char-major-61 lirc_serial" > /etc/modprobe.d/lirc
      echo "options lirc_serial irq=$LIRC_IRQ io=$LIRC_PORT" >> /etc/modprobe.d/lirc
      echo "" >> /etc/modprobe.d/lirc
      depmod
    fi

    # /etc/default/lirc
    MODULES="lirc_dev"
    for i in $LIRC_DRIVER; do
      MODULES="$MODULES lirc_$i"
    done

    echo "# /etc/default/lirc
#
# Arguments which will be used when launching lircd
LIRCD_ARGS=\"--permission=666\"

#Don't start lircmd even if there seems to be a good config file
#START_LIRCMD=false

#Try to load appropriate kernel modules
LOAD_MODULES=true

# Run \"lircd --driver=help\" for a list of supported drivers.
DRIVER=\"default\"
# If DEVICE is set to /dev/lirc and devfs is in use /dev/lirc/0 will be
# automatically used instead
DEVICE=\"/dev/lirc0\"
MODULES=\"$MODULES\"

# Default configuration files for your hardware
LIRCD_CONF=\"/etc/lirc/lircd.conf\"
LIRCMD_CONF=\"/etc/lirc/lircmd.conf\"
"   > /etc/default/lirc

    # copy files
    cd $DIR
    cp -rf lirc /etc
    cp -f lirc_init /etc/init.d/lirc
    chmod 0755 /etc/init.d/lirc

    # autostart
    unfreeze_rc
    update-rc.d lirc defaults 20
    freeze_rc

    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
  fi
}

# clean
function clean_util() {
  if [ "$LINUXVERSION" != "sidux" ]; then
    # uninstall
    apt_remove "lirc liblircclient0"

    # remove source
    cd $SOURCEDIR
    [ -L "$LINK" ] && rm -rf "$LINK"
    [ -d "$VERSION" ] && rm -rf "$VERSION"

    ldconfig
  fi

  # remove config
  rm -rf /etc/lirc
  rm -f /etc/default/lirc
  rm -f /etc/modprobe.d/lirc
  depmod

  # remove autostart
  unfreeze_rc
  update-rc.d -f lirc remove
  freeze_rc
  rm -f /etc/init.d/lirc
}

# test
function status_util() {
  TEST=`which lircd`
  if [ "$TEST" ] && [ -f $LIRC_MODULES/lirc_dev.ko ]; then
    [ "$LINUXVERSION" = "sidux" ] && [ -f /etc/default/lirc ] && echo "2" && return 0
    [ -d $SOURCEDIR/$LINK ] && echo "2" && return 0
    echo "1"
  else
    echo "0"
  fi
}

# commands
if [ $# \> 0 ]; then
  cmd=$1
  cmd_util
else
  make_util
  status_util
fi

exit 0
