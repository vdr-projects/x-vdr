#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 11.09.2008

# x-vdr/plugins.sh

[ -r ./x-vdr.conf ] || exit 1
source ./x-vdr.conf
source ./setup.conf
source ./functions
PDIR="$(pwd)/plugins"

# make plugins
function make_plugins() {
  if [ ! -x $SOURCEDIR/VDR/vdr ]; then
    log "****************************************"
    log "Plugins Fehler - Kann VDR nicht finden! "
    log "****************************************"
    return 1
  fi
  log "****************************************"
  log "Vorbereitungen fuer Plugins ..."
  log "****************************************"
  plugins=`ls $PDIR`
  if [ -n "$plugins" ]; then
    for i in $plugins; do
      if [ -x $PDIR/$i/plugin.sh ]; then
        cd $PDIR/$i
        status=`./plugin.sh --status`
        if [ "${!i}" = "on" ] && [ "$status" = "0" ]; then
          ./plugin.sh
        elif [ "${!i}" = "on" ] && [ "$status" = "2" ]; then
          ./plugin.sh --clean
          ./plugin.sh
        elif [ "${!i}" = "off" ] && [ "$status" != "0" ]; then
          ./plugin.sh --clean
        fi
      fi
    done
  fi
  log "****************************************"
  log "Erstellen der Plugins ..."
  log "****************************************"
  cd $SOURCEDIR/VDR
  make plugins || return 1

  # burn (install burn-buffer)
  if [ "$burn" = "on" ] && [ -f $SOURCEDIR/VDR/PLUGINS/src/burn/burn-buffers ] && [ ! -f $VDRBINDIR/burn-buffers ]; then
    cp -f $SOURCEDIR/VDR/PLUGINS/src/burn/burn-buffers $VDRBINDIR
  fi
  # pin (install fskcheck)
  if [ "$pin" = "on" ] && [ -f $SOURCEDIR/VDR/PLUGINS/src/pin/fskcheck ] && [ ! -f $VDRBINDIR/fskcheck ]; then
    cp -f $SOURCEDIR/VDR/PLUGINS/src/pin/fskcheck $VDRBINDIR
    chmod 0755 $VDRBINDIR/fskcheck
  fi
  # softdevice (install ShmClient)
  if [ "$softdevice" = "on" ] && [ -f $SOURCEDIR/VDR/PLUGINS/src/softdevice/ShmClient ] && [ ! -f $VDRBINDIR/ShmClient ]; then
    cp -f $SOURCEDIR/VDR/PLUGINS/src/softdevice/ShmClient $VDRBINDIR
    chmod 0755 $VDRBINDIR/ShmClient
  fi
  # xineliboutput (install frontends and xine plugins)
  if [ "$xineliboutput" = "on" ]; then
    XINEPLUGINDIR=`xine-config --plugindir`
    if [ ! -f $VDRBINDIR/vdr-fbfe ] || [ ! -f $VDRBINDIR/vdr-sxfe ] || [ -f $XINEPLUGINDIR/xineplug_inp_xvdr.so ]; then
      cd $SOURCEDIR/VDR/PLUGINS/src/xineliboutput
      make install
    fi
  fi

  # copy locale
  if [ -d $SOURCEDIR/VDR/locale ]; then
    [ ! -d $VDRLOCDIR ] && mkdir -p $VDRLOCDIR && log "Erstelle $VDRLOCDIR"
    cp -fR $SOURCEDIR/VDR/locale/* $VDRLOCDIR
  fi

  log "****************************************"
  log "Erstellen der Plugins ist abgeschlossen."
  log "****************************************"
}

make_plugins || exit 1
exit 0
