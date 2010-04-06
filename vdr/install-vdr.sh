#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 10.04.2009

# defaults
VDRVERSION="1.6.0"
MTPATCHES="" # MTPATCHES="1 2 3"
VDROPTIONS="" # hier bitte nur zusaetzliche Optionen eintragen
DIR=$(pwd)

# config files
[ -f ./patchlevel.conf ] && source ./patchlevel.conf
source ./../x-vdr.conf
source ./../setup.conf
# functions
source ./../functions

verify_vdrversion "$VDRVERSION" || exit 1
[ $(( ${VDRVERSION:2:1} % 2 )) -eq 0 ] && VDRWEB="ftp://ftp.tvdr.de/vdr" || VDRWEB="ftp://ftp.tvdr.de/vdr/Developer"

# create error file
error_file="$SOURCEDIR/x-vdr/.error"
echo "install-vdr.sh " > $error_file
log "****************************************"
log "Vorbereitungen fuer den VDR ..."
log "****************************************"

# check input (on/off)
AUTOSTART=`verify_input "$AUTOSTART"`
INS_USER=`verify_input "$INS_USER"`
USEVFAT=`verify_input "$USEVFAT"`
USELIRC=`verify_input "$USELIRC"`
VDRUPDATE=`verify_input "$VDRUPDATE"`
vdr_plugins=`verify_input "$vdr_plugins"`
analogtv=`verify_input "$analogtv"`
burn=`verify_input "$burn"`
channelblocker=`verify_input "$channelblocker"`
dxr3=`verify_input "$dxr3"`
epgsearch=`verify_input "$epgsearch"`
extrecmenu=`verify_input "$extrecmenu"`
graphtft=`verify_input "$graphtft"`
iptv=`verify_input "$iptv"`
menuorg=`verify_input "$menuorg"`
noepgmenu=`verify_input "$noepgmenu"`
pin=`verify_input "$pin"`
pvrinput=`verify_input "$pvrinput"`
pvrusb2=`verify_input "$pvrusb2"`
reelbox=`verify_input "$reelbox"`
reelchannelscan=`verify_input "$reelchannelscan"`
remoteosd=`verify_input "$remoteosd"`
remotetimers=`verify_input "$remotetimers"`
rotor=`verify_input "$rotor"`
setup=`verify_input "$setup"`
submenu=`verify_input "$submenu"`
subtitles=`verify_input "$subtitles"`
ttxtsubs=`verify_input "$ttxtsubs"`
yaepg=`verify_input "$yaepg"`
verify_patchlevel

# pre-install
if [ ! -d $SOURCEDIR/DVB ]; then
  if [ -d /usr/include/linux/dvb ]; then
    if [ ! -f /usr/include/linux/compiler.h ]; then
      cd /usr/include/linux
      if [ -f /usr/src/linux/include/linux/compiler.h ]; then
        ln -s /usr/src/linux/include/linux/compiler.h compiler.h
      elif [ -f /usr/src/$(uname -r)/include/linux/compiler.h ]; then
        ln -s /usr/src/$(uname -r)/include/linux/compiler.h compiler.h
      elif [ -f /usr/src/linux-headers-$(uname -r)/include/linux/compiler.h ]; then
        ln -s /usr/src/linux-headers-$(uname -r)/include/linux/compiler.h compiler.h
      else
        log "***************************************"
        log "VDR Fehler! - compiler.h nicht gefunden"
        log "***************************************"
        echo "- /usr/src/linux/include/linux/compiler.h nicht gefunden." >> $error_file
        exit 1
      fi
    fi
  else
    log "****************************************"
    log "VDR Fehler! - DVB Treiber nicht gefunden"
    log "****************************************"
    echo "- dvb-treiber nicht gefunden." >> $error_file
    exit 1
  fi
fi

# DVB_API_VERSION
get_dvbapi

## VDR-Source
# download VDR-Source
if [ ! -f $FILES/vdr/vdr-$VDRVERSION.tar.bz2 ]; then
  log "vdr-$VDRVERSION.tar.bz2 nicht gefunden"
  log "Starte download"
  wget --tries=2 "$VDRWEB/vdr-$VDRVERSION.tar.bz2" --directory-prefix="$FILES/vdr"
else
  log "vdr-$VDRVERSION.tar.bz2 gefunden"
fi

if [ ! -f "$FILES/vdr/vdr-$VDRVERSION.tar.bz2" ]; then
  log "****************************************"
  log "VDR Fehler!"
  log "vdr-$VDRVERSION.tar.bz2 nicht gefunden"
  log "****************************************"
  echo "- vdr-$VDRVERSION.tar.bz2 konnte nicht geladen werden" >> $error_file
  exit 1
fi

# untar VDR-Source
tar xjf "$FILES/vdr/vdr-$VDRVERSION.tar.bz2" -C $SOURCEDIR && log "Extrahiere vdr-$VDRVERSION.tar.bz2"

# create VDR-Symlink
cd $SOURCEDIR
ln -vnfs vdr-$VDRVERSION VDR

# create vdruser
[ "$VDRUPDATE" != "on" ] && make_user

# create Directories
[ "$VDRUPDATE" != "on" ] && make_dirs

# create VDR make.config
function make_makeconfig() {
  MAKECONFIG="$SOURCEDIR/VDR/Make.global"
  [ -f $MAKECONFIG ] && mv -f $MAKECONFIG $MAKECONFIG.old

  {
    echo "#"
    echo "# User defined Makefile options for the Video Disk Recorder"
    echo "#"
    echo "# Copy this file to 'Make.config' and change the parameters as necessary."
    echo "#"
    echo "# See the main source file 'vdr.c' for copyright information and"
    echo "# how to reach the author."
    echo "#"
    echo "# \$Id: Make.config.template 1.10 2006/06/15 09:15:25 kls Exp \$"
    echo ""
    echo "# $(date)"
    echo "# modified for x-vdr"
    echo ""
    echo "### The C compiler and options:"
    echo "CC       = gcc"
    echo "CFLAGS   = -g -O2 -Wall"
    echo ""
    echo "CXX      = g++"
    echo "CXXFLAGS = -g -O2 -Wall -Woverloaded-virtual"
    echo ""
    echo "ifdef PLUGIN"
    echo "CFLAGS   += -fPIC"
    echo "CXXFLAGS += -fPIC"
    if [ ${VDRVERSION:2:1} -gt 6 -a ${VDRVERSION:4:1} -gt 2 -o ${VDRVERSION:2:1} -gt 7 ]; then
      echo "DEFINES  += -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE"
    fi
    echo "endif"
    echo ""
    echo "DEFINES += -D__KERNEL_STRICT_NAMES"
    echo ""
    echo "### The directory environment:"
    echo ""
    if [ -f "$SOURCEDIR/DVB/linux/include/linux/dvb/version.h" ]; then
      echo "DVBDIR= $SOURCEDIR/DVB/linux"
    else
      echo "#DVBDIR= $SOURCEDIR/v4l-dvb/linux"
    fi
    echo "MANDIR= $VDRMANDIR"
    echo "BINDIR= $VDRBINDIR"
    echo ""
    echo "LOCDIR= $VDRLOCDIR"
    echo "PLUGINDIR= ./PLUGINS"
    echo "PLUGINLIBDIR= $VDRLIBDIR"
    echo "VIDEODIR= $VIDEODIR"
    echo "CONFDIR= $VDRCONFDIR"
    echo ""
    echo "LIBDIR= \$(PLUGINLIBDIR)"
    echo ""
    echo "### The remote control:"
    echo ""
    echo "LIRC_DEVICE = /dev/lircd"
    echo "RCU_DEVICE  = /dev/ttyS1"
    echo ""
    echo "## Define if you want vdr to not run as root"
    echo "#VDR_USER = $VDRUSER"
    echo ""
    echo "### Extra Options:"
    echo ""

    if [ "$USELIRC" = "on" ]; then
      echo "REMOTE= LIRC"
    else
      echo "#REMOTE= LIRC"
    fi

    if [ "$USEVFAT" = "on" ]; then
      echo "VFAT= 1"
    else
      echo "#VFAT= 1"
    fi

    if [ "$dxr3" = "on" ]; then
      echo "EM8300= $SOURCEDIR/em8300/include"
    fi

    if [ "$ffmpeg" = "on" ]; then
      echo "FFMDIR= $SOURCEDIR/ffmpeg"
    else
      echo "FFMDIR= /usr/include/ffmpeg"
    fi

    if [ "$burn" = "on" ]; then
      echo "DVDDEV= $DVDBURNER"
      echo "ISODIR= $DVDISODIR"
    fi

    if [ "$tvm2vdr" = "on" ]; then
      echo "DEFINES += -DTVM2VDR_DATA_DIR=$VDRVARDIR"
    else
      echo "#DEFINES += -DTVM2VDR_DATA_DIR=$VDRVARDIR"
    fi

    if [ "$PATCHLEVEL" = "EXTENSIONS" ]; then
      echo ""
      echo "### VDR-Extensions:"
      echo "# Comment the patches you don't need"
      echo "# DVDCHAPJUMP needs DVDARCHIVE enabled"
      echo "# DVDARCHIVE needs LIEMIEXT enabled"
      echo "# SORTRECORDS needs LIEMIEXT enabled"
      echo "# you can only enable one of MENUORG SUBMENU SETUP"
      echo ""

      if [ "$ANALOGTV" = "on" ] || [ "$analogtv" = "on" ] || [ "$pvrinput" = "on" ] || [ "$pvrusb2" = "on" ]; then
        echo "ANALOGTV = 1"
      else
        echo "#ANALOGTV = 1"
      fi

      if [ "$ATSC" = "on" ]; then
        echo "ATSC = 1"
      else
        echo "#ATSC = 1"
      fi

      if [ "$CHANNELSCAN" = "on" ] || [ "$reelchannelscan" = "on" ]; then
        echo "CHANNELSCAN = 1"
      else
        echo "#CHANNELSCAN = 1"
      fi

      if [ "$CMDRECCMDI18N" = "on" ]; then
        echo "CMDRECCMDI18N = 1"
      else
        echo "#CMDRECCMDI18N = 1"
      fi

      if [ "$CMDSUBMENU" = "on" ]; then
        echo "CMDSUBMENU = 1"
      else
        echo "#CMDSUBMENU = 1"
      fi

      if [ "$CUTTERLIMIT" = "on" ]; then
        echo "CUTTERLIMIT = 1"
      else
        echo "#CUTTERLIMIT = 1"
      fi

      if [ "$CUTTERQUEUE" = "on" ]; then
        echo "CUTTERQUEUE = 1"
      else
        echo "#CUTTERQUEUE = 1"
      fi

      if [ "$CUTTIME" = "on" ]; then
        echo "CUTTIME = 1"
      else
        echo "#CUTTIME = 1"
      fi

      if [ "$DELTIMESHIFTREC" = "on" ]; then
        echo "DELTIMESHIFTREC = 1"
      else
        echo "#DELTIMESHIFTREC = 1"
      fi

      if [ "$DDEPGENTRY" = "on" ]; then
        echo "DDEPGENTRY = 1"
      else
        echo "#DDEPGENTRY = 1"
      fi

      if [ "$DOLBYINREC" = "on" ]; then
        echo "DOLBYINREC = 1"
      else
        echo "#DOLBYINREC = 1"
      fi

      if [ "$DVBPLAYER" = "on" ]; then
        echo "DVBPLAYER = 1"
      else
        echo "#DVBPLAYER = 1"
      fi

      if [ "$DVBSETUP" = "on" ] || [ "$channelblocker" = "on" ]; then
        echo "DVBSETUP = 1"
      else
        echo "#DVBSETUP = 1"
      fi

      if [ "$DVDARCHIVE" = "on" ]; then
        echo "DVDARCHIVE = 1"
      else
        echo "#DVDARCHIVE = 1"
      fi

      if [ "$DVDCHAPJUMP" = "on" ]; then
        echo "DVDCHAPJUMP = 1"
      else
        echo "#DVDCHAPJUMP = 1"
      fi

      if [ "$DVLFRIENDLYFNAMES" = "on" ]; then
        echo "DVLFRIENDLYFNAMES = 1"
      else
        echo "#DVLFRIENDLYFNAMES = 1"
      fi

      if [ "$DVLRECSCRIPTADDON" = "on" ]; then
        echo "DVLRECSCRIPTADDON = 1"
      else
        echo "#DVLRECSCRIPTADDON = 1"
      fi

      if [ "$DVLVIDPREFER" = "on" ]; then
        echo "DVLVIDPREFER = 1"
      else
        echo "#DVLVIDPREFER = 1"
      fi

      if [ "$EM84XX" = "on" ] || [ "$em84xx" = "on" ]; then
        echo "EM84XX = 1"
      else
        echo "#EM84XX = 1"
      fi

      if [ "$GOTOX" = "on" ]; then
        echo "GOTOX = 1"
      else
        echo "#GOTOX = 1"
      fi

      if [ "$GRAPHTFT" = "on" ] || [ "$graphtft" = "on" ]; then
        echo "GRAPHTFT = 1"
      else
        echo "#GRAPHTFT = 1"
      fi

      if [ "$HARDLINKCUTTER" = "on" ]; then
        echo "HARDLINKCUTTER = 1"
      else
        echo "#HARDLINKCUTTER = 1"
      fi

      if [ "$JUMPPLAY" = "on" ]; then
        echo "JUMPPLAY = 1"
      else
        echo "#JUMPPLAY = 1"
      fi

      if [ "$LIEMIEXT" = "on" ]; then
        echo "LIEMIEXT = 1"
      else
        echo "#LIEMIEXT = 1"
      fi

      if [ "$LIRCSETTINGS" = "on" ]; then # || [ "$USELIRC" = "on" ]
        echo "LIRCSETTINGS = 1"
      else
        echo "#LIRCSETTINGS = 1"
      fi

      if [ "$LIVEBUFFER" = "on" ]; then
        echo "LIVEBUFFER = 1"
      else
        echo "#LIVEBUFFER = 1"
      fi

      if [ "$LNBSHARE" = "on" ]; then
        echo "LNBSHARE = 1"
      else
        echo "#LNBSHARE = 1"
      fi

      if [ "$MAINMENUHOOKS" = "on" ] || [ "$epgsearch" = "on" ] || [ "$extrecmenu" = "on" ] || [ "$remoteosd" = "on" ] || [ "$remotetimers" = "on" ]; then
        echo "MAINMENUHOOKS = 1"
      else
        echo "#MAINMENUHOOKS = 1"
      fi

      if [ "$MENUORG" = "on" ] || [ "$menuorg" = "on" ]; then
        SETUP="off"
        setup="off"
        SUBMENU="off"
        submenu="off"
        echo "MENUORG = 1"
      else
        echo "#MENUORG = 1"
      fi

      if [ "$NOEPG" = "on" ] || [ "$noepgmenu" = "on" ]; then
        echo "NOEPG = 1"
      else
        echo "#NOEPG = 1"
      fi

      if [ "$OSDMAXITEMS" = "on" ] || [ "$text2skin" = "on" ]; then
        echo "OSDMAXITEMS = 1"
      else
        echo "#OSDMAXITEMS = 1"
      fi

      if [ "$PARENTALRATING" = "on" ]; then
        echo "PARENTALRATING = 1"
      else
        echo "#PARENTALRATING = 1"
      fi

      if [ "$PINPLUGIN" = "on" ] || [ "$pin" = "on" ]; then
        echo "PINPLUGIN = 1"
      else
        echo "#PINPLUGIN = 1"
      fi

      if [ "$PLUGINAPI" = "on" ]; then
        echo "PLUGINAPI = 1"
      else
        echo "#PLUGINAPI = 1"
      fi

      if [ "$PLUGINMISSING" = "on" ]; then
        echo "PLUGINMISSING = 1"
      else
        echo "#PLUGINMISSING = 1"
      fi

      if [ "$PLUGINPARAM" = "on" ] || [ "$iptv" = "on" ]; then
        echo "PLUGINPARAM = 1"
      else
        echo "#PLUGINPARAM = 1"
      fi

      if [ "$REELPLUGIN" = "on" ] || [ "$reelbox" = "on" ]; then
        echo "REELPLUGIN = 1"
      else
        echo "#REELPLUGIN = 1"
      fi

      if [ "$ROTOR" = "on" ] || [ "$rotor" = "on" ]; then
        echo "ROTOR = 1"
      else
        echo "#ROTOR = 1"
      fi

      if [ "$SETTIME" = "on" ]; then
        echo "SETTIME = 1"
      else
        echo "#SETTIME = 1"
      fi

      if [ "$SETUP" = "on" ] || [ "$setup" = "on" ]; then
        echo "SETUP = 1"
        SUBMENU="off"
        submenu="off"
      else
        echo "#SETUP = 1"
      fi

      if [ "$SOFTOSD" = "on" ]; then
        echo "SOFTOSD = 1"
      else
        echo "#SOFTOSD = 1"
      fi

      if [ "$SOURCECAPS" = "on" ]; then
        echo "SOURCECAPS = 1"
      else
        echo "#SOURCECAPS = 1"
      fi

      if [ "$SORTRECORDS" = "on" ]; then
        echo "SORTRECORDS = 1"
      else
        echo "#SORTRECORDS = 1"
      fi

      if [ "$SUBMENU" = "on" ] || [ "$submenu" = "on" ]; then
        echo "SUBMENU = 1"
      else
        echo "#SUBMENU = 1"
      fi

      if [ "$STREAMDEVEXT" = "on" ]; then
        echo "STREAMDEVEXT = 1"
      else
        echo "#STREAMDEVEXT = 1"
      fi

      if [ "$SYNCEARLY" = "on" ]; then
        echo "SYNCEARLY = 1"
      else
        echo "#SYNCEARLY = 1"
      fi

      if [ "$TIMERCMD" = "on" ]; then
        echo "TIMERCMD = 1"
      else
        echo "#TIMERCMD = 1"
      fi

      if [ "$TIMERINFO" = "on" ]; then
        echo "TIMERINFO = 1"
      else
        echo "#TIMERINFO = 1"
      fi

      if [ "$TTXTSUBS" = "on" ] || [ "$ttxtsubs" = "on" ]; then
        echo "TTXTSUBS = 1"
      else
        echo "#TTXTSUBS = 1"
      fi

      if [ "$VALIDINPUT" = "on" ]; then
        echo "VALIDINPUT = 1"
      else
        echo "#VALIDINPUT = 1"
      fi

      if [ "$VOLCTRL" = "on" ]; then
        echo "VOLCTRL = 1"
      else
        echo "#VOLCTRL = 1"
      fi

      if [ "$WAREAGLEICON" = "on" ]; then
        echo "WAREAGLEICON = 1"
      else
        echo "#WAREAGLEICON = 1"
      fi

      if [ "$YAEPG" = "on" ] || [ "$yaepg" = "on" ]; then
        echo "YAEPG = 1"
      else
        echo "#YAEPG = 1"
      fi
    fi
    echo ""
    echo ""
    echo "### You don't need to touch the following:"
    echo ""
    echo "ifdef DVBDIR"
    echo "INCLUDES += -I\$(DVBDIR)/include"
    echo "endif"
    echo ""
    if [ "$PATCHLEVEL" = "EXTENSIONS" ]; then
      echo "ifdef ANALOGTV"
      echo "DEFINES += -DUSE_ANALOGTV"
      echo "endif"
      echo ""
      echo "ifdef ATSC"
      echo "DEFINES += -DUSE_ATSC"
      echo "endif"
      echo ""
      echo "ifdef CHANNELSCAN"
      echo "DEFINES += -DUSE_CHANNELSCAN"
      echo "endif"
      echo ""
      echo "ifdef CMDRECCMDI18N"
      echo "DEFINES += -DUSE_CMDRECCMDI18N"
      echo "endif"
      echo ""
      echo "ifdef CMDSUBMENU"
      echo "DEFINES += -DUSE_CMDSUBMENU"
      echo "endif"
      echo ""
      echo "ifdef CUTTERLIMIT"
      echo "DEFINES += -DUSE_CUTTERLIMIT"
      echo "endif"
      echo ""
      echo "ifdef CUTTERQUEUE"
      echo "DEFINES += -DUSE_CUTTERQUEUE"
      echo "endif"
      echo ""
      echo "ifdef CUTTIME"
      echo "DEFINES += -DUSE_CUTTIME"
      echo "endif"
      echo ""
      echo "ifdef DELTIMESHIFTREC"
      echo "DEFINES += -DUSE_DELTIMESHIFTREC"
      echo "endif"
      echo ""
      echo "ifdef DDEPGENTRY"
      echo "DEFINES += -DUSE_DDEPGENTRY"
      echo "endif"
      echo ""
      echo "ifdef DOLBYINREC"
      echo "DEFINES += -DUSE_DOLBYINREC"
      echo "endif"
      echo ""
      echo "ifdef DVBPLAYER"
      echo "DEFINES += -DUSE_DVBPLAYER"
      echo "endif"
      echo ""
      echo "ifdef DVBSETUP"
      echo "DEFINES += -DUSE_DVBSETUP"
      echo "endif"
      echo ""
      echo "ifdef DVDARCHIVE"
      echo "ifdef LIEMIEXT"
      echo "DEFINES += -DUSE_DVDARCHIVE"
      echo "endif"
      echo "endif"
      echo ""
      echo "ifdef DVLRECSCRIPTADDON"
      echo "DEFINES += -DUSE_DVLRECSCRIPTADDON"
      echo "endif"
      echo ""
      echo "ifdef DVLVIDPREFER"
      echo "DEFINES += -DUSE_DVLVIDPREFER"
      echo "endif"
      echo ""
      echo "ifdef DVLFRIENDLYFNAMES"
      echo "DEFINES += -DUSE_DVLFRIENDLYFNAMES"
      echo "endif"
      echo ""
      echo "ifdef EM84XX"
      echo "DEFINES += -DUSE_EM84XX"
      echo "endif"
      echo ""
      echo "ifdef GOTOX"
      echo "DEFINES += -DUSE_GOTOX"
      echo "endif"
      echo ""
      echo "ifdef GRAPHTFT"
      echo "DEFINES += -DUSE_GRAPHTFT"
      echo "endif"
      echo ""
      echo "ifdef HARDLINKCUTTER"
      echo "DEFINES += -DUSE_HARDLINKCUTTER"
      echo "endif"
      echo ""
      echo "ifdef JUMPPLAY"
      echo "DEFINES += -DUSE_JUMPPLAY"
      echo "endif"
      echo ""
      echo "ifdef LIEMIEXT"
      echo "DEFINES += -DUSE_LIEMIEXT"
      echo "endif"
      echo ""
      echo "ifdef LIRCSETTINGS"
      echo "DEFINES += -DUSE_LIRCSETTINGS"
      echo "endif"
      echo ""
      echo "ifdef LIVEBUFFER"
      echo "DEFINES += -DUSE_LIVEBUFFER"
      echo "endif"
      echo ""
      echo "ifdef LNBSHARE"
      echo "DEFINES += -DUSE_LNBSHARE"
      echo "endif"
      echo ""
      echo "ifdef MAINMENUHOOKS"
      echo "DEFINES += -DUSE_MAINMENUHOOKS"
      echo "endif"
      echo ""
      echo "ifdef MENUORG"
      echo "DEFINES += -DUSE_MENUORG"
      echo "else"
      echo "ifdef SETUP"
      echo "DEFINES += -DUSE_SETUP"
      echo "else"
      echo "ifdef SUBMENU"
      echo "DEFINES += -DUSE_SUBMENU"
      echo "endif"
      echo "endif"
      echo "endif"
      echo ""
      echo "ifdef NOEPG"
      echo "DEFINES += -DUSE_NOEPG"
      echo "endif"
      echo ""
      echo "ifdef OSDMAXITEMS"
      echo "DEFINES += -DUSE_OSDMAXITEMS"
      echo "endif"
      echo ""
      echo "ifdef PARENTALRATING"
      echo "DEFINES += -DUSE_PARENTALRATING"
      echo "endif"
      echo ""
      echo "ifdef PINPLUGIN"
      echo "DEFINES += -DUSE_PINPLUGIN"
      echo "endif"
      echo ""
      echo "ifdef PLUGINMISSING"
      echo "DEFINES += -DUSE_PLUGINMISSING"
      echo "endif"
      echo ""
      echo "ifdef PLUGINPARAM"
      echo "DEFINES += -DUSE_PLUGINPARAM"
      echo "endif"
      echo ""
      echo "ifdef REELPLUGIN"
      echo "DEFINES += -DUSE_REELPLUGIN"
      echo "endif"
      echo ""
      echo "ifdef ROTOR"
      echo "DEFINES += -DUSE_ROTOR"
      echo "endif"
      echo ""
      echo "ifdef SETTIME"
      echo "DEFINES += -DUSE_SETTIME"
      echo "endif"
      echo ""
      echo "ifdef SOFTOSD"
      echo "DEFINES += -DUSE_SOFTOSD"
      echo "endif"
      echo ""
      echo "ifdef SOURCECAPS"
      echo "DEFINES += -DUSE_SOURCECAPS"
      echo "endif"
      echo ""
      echo "ifdef SORTRECORDS"
      echo "ifdef LIEMIEXT"
      echo "DEFINES += -DUSE_SORTRECORDS"
      echo "endif"
      echo "endif"
      echo ""
      echo "ifdef STREAMDEVEXT"
      echo "DEFINES += -DUSE_STREAMDEVEXT"
      echo "endif"
      echo ""
      echo "ifdef SYNCEARLY"
      echo "DEFINES += -DUSE_SYNCEARLY"
      echo "endif"
      echo ""
      echo "ifdef TIMERCMD"
      echo "DEFINES += -DUSE_TIMERCMD"
      echo "endif"
      echo ""
      echo "ifdef TIMERINFO"
      echo "DEFINES += -DUSE_TIMERINFO"
      echo "endif"
      echo ""
      echo "ifdef TTXTSUBS"
      echo "DEFINES += -DUSE_TTXTSUBS"
      echo "endif"
      echo ""
      echo "ifdef VALIDINPUT"
      echo "DEFINES += -DUSE_VALIDINPUT"
      echo "endif"
      echo ""
      echo "ifdef VOLCTRL"
      echo "DEFINES += -DUSE_VOLCTRL"
      echo "endif"
      echo ""
      echo "ifdef WAREAGLEICON"
      echo "DEFINES += -DUSE_WAREAGLEICON"
      echo "endif"
      echo ""
      echo "ifdef YAEPG"
      echo "DEFINES += -DUSE_YAEPG"
      echo "endif"
      echo ""
    else
      if [ "$setup" = "on" ] || [ "$SETUP" = "on" ]; then
        echo "DEFINES += -DUSE_LIVEBUFFER"
        echo ""
      fi
    fi
  } > $MAKECONFIG
}
make_makeconfig
cd $SOURCEDIR/VDR
cp Make.global Make.config
## patch VDR
cd $SOURCEDIR/VDR

# download vdr-maintenance patches
if [ -n "$MTPATCHES" ]; then
  for n in $MTPATCHES; do
    if [ -f $DIR/maintenance/vdr-$VDRVERSION-$n.diff ]; then
      log "vdr-$VDRVERSION-$n.diff gefunden"
    else
      wget -q --tries=1 "$VDRWEB/Developer/vdr-$VDRVERSION-$n.diff" --directory-prefix="$DIR/maintenance"
      [ ! -f $DIR/maintenance/vdr-$VDRVERSION-$n.diff ] && break
      log "vdr-$VDRVERSION-$n.diff geladen"
    fi
  done
fi

# apply vdr-maintenance patches
for i in `ls $DIR/maintenance | grep "vdr-$VDRVERSION-.*.diff$"`; do
  log "apply $i"
  patch -f -p 1 < $DIR/maintenance/$i
done

# check if dvb-api-wrapper is needed
if [ ${VDRVERSION:2:1} -gt 6 ] && [ "$PATCHLEVEL" != "PLAIN" ]; then
  if [ $DVB_API_VERSION -lt 5 -a ${VDRVERSION:4:1} -gt 1 -o ${VDRVERSION:2:1} -gt 7 ] ||
     [ $DVB_API_VERSION -eq 3 -a $DVB_API_VERSION_MINOR -lt 3 ]; then
    api_wrapper_patch=$(ls -r $DIR | grep -m1 "^vdr-$VDRVERSION.*s2apiwrapper.*.diff$")
    [ -n "$api_wrapper_patch" ] || api_wrapper_patch=$(ls -r $DIR | grep -m1 "^vdr-1.7.*s2apiwrapper.*.diff$")
    if [ -n "$api_wrapper_patch" ]; then
      log "apply $api_wrapper_patch"
      patch -f -p 1 < $DIR/$api_wrapper_patch
    else
      echo "- DVB_API_VERSION < 5 und api_wrapper_patch nicht gefunden." >> $error_file
      log "DVB_API_VERSION < 5 und api_wrapper_patch nicht gefunden"
      exit 1
    fi
  fi
fi

# apply extensions
if [ "$PATCHLEVEL" = "EXTENSIONS" ]; then
  extensions_patch=$(ls -r $DIR/extensions | grep -m1 "^vdr-${VDRVERSION}_extensions.diff$")
  [ -n "$extensions_patch" ] || extensions_patch=$(ls -r $DIR/extensions | grep -m1 "^vdr-${VDRVERSION}.*_extensions.diff$")
  [ -n "$extensions_patch" ] || extensions_patch=$(ls -r $DIR/extensions | grep -m1 "^vdr-.*_extensions.diff$")
  if [ -n "$extensions_patch" ]; then
    log "apply $extensions_patch"
    patch -f -p 1 < $DIR/extensions/$extensions_patch
    # search for more extensions
    for i in `ls $DIR/extensions | grep "^vdr-${VDRVERSION}.*-ext.*_.*.diff$"`; do
      log "apply $i"
      patch -f -p 1 < $DIR/extensions/$i
    done
  else
    echo "- Extensions-Patch nicht gefunden." >> $error_file
    log "Extensions-Patch nicht gefunden"
    exit 1
  fi
fi

if [ "$PATCHLEVEL" != "PLAIN" ]; then
  # search for *.bz2
  for i in `ls $DIR/patches | grep ".bz2$"`; do
    log "apply $i"
    bzcat $DIR/patches/$i | patch -f -p 1
  done
  # search for *.diff
  for i in `ls $DIR/patches | grep ".diff$"`; do
    log "apply $i"
    patch -f -p 1 < $DIR/patches/$i
  done
  # search for *.patch
  for i in `ls $DIR/patches | grep ".patch$"`; do
    log "apply $i"
    patch -f -p 1 < $DIR/patches/$i
  done
fi

# remove default plugins
if [ "$vdr_plugins" = "off" ]; then
  rm -rf $SOURCEDIR/VDR/PLUGINS/src/hello
  rm -rf $SOURCEDIR/VDR/PLUGINS/src/osddemo
  rm -rf $SOURCEDIR/VDR/PLUGINS/src/pictures
  rm -rf $SOURCEDIR/VDR/PLUGINS/src/servicedemo
  rm -rf $SOURCEDIR/VDR/PLUGINS/src/skincurses
  rm -rf $SOURCEDIR/VDR/PLUGINS/src/sky
  rm -rf $SOURCEDIR/VDR/PLUGINS/src/status
  rm -rf $SOURCEDIR/VDR/PLUGINS/src/svdrpdemo
fi

# make VDR
log "****************************************"
log "Erstellen des VDR ..."
log "****************************************"
cd $SOURCEDIR/VDR
make $VDROPTIONS

# copy instead of make install
if ! cp -f vdr $VDRPRG ; then
  log "****************************************"
  log "Fehler! - VDR wurde nicht erstellt."
  log "****************************************"
  echo "- $VDRPRG konnte nicht erstellt werden." >> $error_file
  exit 1
fi

# copy locale
if [ -d $SOURCEDIR/VDR/locale ]; then
  [ ! -d $VDRLOCDIR ] && mkdir -p $VDRLOCDIR && log "Erstelle $VDRLOCDIR"
  cp -fR $SOURCEDIR/VDR/locale/* $VDRLOCDIR
fi

# stop if VDRUPDATE=on
if [ "$VDRUPDATE" = "on" ]; then
  log "****************************************"
  log "Aktualisierung des VDR erfolgreich."
  log "****************************************"
  # delete error file
  [ -f $error_file ] && rm -f $error_file
  exit 0
fi

# copy / create files
function make_files() {
  # kopiere man1 und man5
  gzip -c vdr.1 > $VDRMANDIR/man1/vdr.1.gz
  gzip -c vdr.5 > $VDRMANDIR/man5/vdr.5.gz
  # vdr-config dateien kopieren
  cd $SOURCEDIR/VDR
  cp -f svdrpsend.pl $VDRBINDIR
  cp -f *.conf $VDRCONFDIR
  # config dateien erstellen
  cd $SOURCEDIR/x-vdr/vdr
  ./make-conf.sh
  # eigene config dateien kopieren
  cd $SOURCEDIR/x-vdr/vdr/conf
  cp -f *.conf $VDRCONFDIR
  cp -f _xinitrc $VDRCONFDIR/.xinitrc
  # Kanallisten kopieren
  [ -d $SOURCEDIR/x-vdr/extra/channellists ] && cp -fR $SOURCEDIR/x-vdr/extra/channellists  $VDRCONFDIR
  # eigene scripte kopieren
  cd $SOURCEDIR/x-vdr/vdr/scripts
  # runvdr
  cp -f runvdr $VDRBINDIR
  # dvd-bc
  cp -f burn-bc $VDRBINDIR
  # vdrplayer
  cp -f vdrplayer $VDRBINDIR
  # vdr2root
  cp -f vdr2root $VDRSCRIPTDIR
  # vdrmount
  cp -f vdrmount $VDRSCRIPTDIR
  # noad
  cp -f vdrnoad $VDRSCRIPTDIR
  # shutdown
  cp -f vdrshutdown $VDRSCRIPTDIR
  # reccmds
  cp -f vdrreccmds $VDRSCRIPTDIR
  # settime
  cp -f vdrsettime $VDRSCRIPTDIR
  # vdrsetup
  cp -f vdrsetup $VDRSCRIPTDIR
  # vdrreaddvd
  cp -f vdrreaddvd $VDRSCRIPTDIR
  # vdrwritedvd
  cp -f vdrwritedvd $VDRSCRIPTDIR
  # timerrep.sh
  cp -f timerrep.sh $VDRSCRIPTDIR
  # kopiere vdr init script
  cp -f vdr /etc/init.d

  # rechte setzen
  chmod 0755 $VDRBINDIR/runvdr
  chmod 0755 $VDRBINDIR/burn-bc
  chmod 0755 $VDRBINDIR/vdrplayer
  chmod 0755 /etc/init.d/vdr
  chmod -R 0744 $VDRSCRIPTDIR

  # mkdir DVD-VCD
  if [ ! -d $MEDIADIR/DVD-VCD ]; then
    mkdir -p $MEDIADIR/DVD-VCD
    touch $MEDIADIR/DVD-VCD/DVD $MEDIADIR/DVD-VCD/VCD
    chmod 0666 $MEDIADIR/DVD-VCD/DVD $MEDIADIR/DVD-VCD/VCD
  fi

  chown -R $VDRUSER:$VDRGROUP $VDRCONFDIR $VDRSCRIPTDIR $VDRVARDIR $VIDEODIR $MUSICDIR $DIVXDIR $DVDISODIR $MEDIADIR $PICTUREDIR
}
make_files

# autostart VDR
[ "$AUTOSTART" = "on" ] && make_autostart

cd $SOURCEDIR

# create /etc/default/vdr
make_default
log "****************************************"
log "VDR Installation erfolgreich."
log "****************************************"

# delete error file
[ -f $error_file ] && rm -f $error_file

exit 0

