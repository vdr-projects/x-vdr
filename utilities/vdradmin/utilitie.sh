#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 24.01.2009

# vdradmin

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://andreas.vdr-developer.org/vdradmin-am/download/vdradmin-am-3.6.7.tar.bz2"
VERSION="vdradmin-am-3.6.7"
LINK="vdradmin"

VAR=`basename $WEB`
DIR=`pwd`

# install
function make_util() {
  download_util
  extract_util

  # setzen des symlinks
  cd $SOURCEDIR
  rm -f $LINK
  rm -rf /usr/share/vdradmin
  ln -vfs $VERSION $LINK
  mkdir /var/cache/vdradmin
  mkdir /var/log/vdradmin
  mkdir /var/run/vdradmin
  # vdradmin-am
  cd $SOURCEDIR/$LINK
  # patch ./install.sh (comment this if you want to install the "Optional" perl-modules for vdradmin-am)
  find $DIR/patches -name vdradmin-am-autoinstall.diff -exec patch -i \{} \;

  # start the original install.sh
  chmod 0744 ./install.sh
  if ./install.sh && [ -f /usr/bin/vdradmind ]; then

    # /etc/init.d/vdradmin-am
    if [ -f $DIR/vdradmin-am ]; then
      cp -f $DIR/vdradmin-am /etc/init.d
      chmod 0755 /etc/init.d/vdradmin-am
      [ "$AUTOSTART" = "on" ] && make_autostart vdradmin-am
    fi

    # /usr/bin/vdradmind.conf
#   export LANG="de_DE" && vdradmind.pl --config
    if [ -f $DIR/vdradmind.conf ]; then
      cp -f $DIR/vdradmind.conf /etc/vdradmin
    else

echo "AT_DESC = 0
AT_FUNC = 1
AT_LIFETIME = 99
AT_MARGIN_BEGIN = 10
AT_MARGIN_END = 10
AT_OFFER = 0
AT_PRIORITY = 99
AT_SENDMAIL = 0
AT_SORTBY = pattern
AT_TIMEOUT = 120
AT_TOOLTIP = 1
AUTO_SAVE_CONFIG = 1
CACHE_LASTUPDATE = 0
CACHE_REC_LASTUPDATE = 0
CACHE_REC_TIMEOUT = 60
CACHE_TIMEOUT = 60
CHANNELS_WANTED = 
CHANNELS_WANTED_AUTOTIMER = 
CHANNELS_WANTED_PRG = 
CHANNELS_WANTED_PRG2 = 
CHANNELS_WANTED_SUMMARY = 
CHANNELS_WANTED_TIMELINE = 
CHANNELS_WANTED_WATCHTV = 
CMD_LINES = 20
EPG_DIRECT = 0
EPG_FILENAME = $VDRVARDIR/epg.data
EPGIMAGES = $VDRVARDIR
EPG_PRUNE = 0
ES_DESC = 0
ES_SORTBY = pattern
GUEST_ACCOUNT = 0
LANG = 
LOCAL_NET = 0.0.0.0/32
LOGFILE = vdradmind.log
LOGGING = 0
LOGINPAGE = 0
LOGLEVEL = 81
MAIL_AUTH_PASS = 
MAIL_AUTH_USER = 
MAIL_FROM = from@address.tld
MAIL_SERVER = your.email.server
MAIL_TO = your@email.address
MOD_GZIP = 0
NO_EVENTID = 0
NO_EVENTID_ON = 
PASSWORD = linvdr
PASSWORD_GUEST = guest
PROG_SUMMARY_COLS = 3
PS_VIEW = ext
REC_DESC = 0
REC_EXT = m3u
REC_MIMETYPE = video/x-mpegurl
RECORDINGS = 1
REC_SORTBY = name
SERVERHOST = 0.0.0.0
SERVERPORT = 8001
SKIN = default
ST_FUNC = 1
ST_LIVE_ON = 1
ST_REC_ON = 0
ST_STREAMDEV_PORT = 3000
ST_URL = 
ST_VIDEODIR = 
TEMPLATE = default
TIMES = 18:00, 20:00, 21:00, 22:00
TL_TOOLTIP = 1
TM_DESC = 0
TM_LIFETIME = 99
TM_MARGIN_BEGIN = 10
TM_MARGIN_END = 10
TM_PRIORITY = 99
TM_SORTBY = day
TM_TT_LIST = 1
TM_TT_TIMELINE = 1
TV_EXT = m3u
TV_INTERVAL = 5
TV_MIMETYPE = video/x-mpegurl
TV_SIZE = half
USERNAME = linvdr
USERNAME_GUEST = guest
VDRCONFDIR = $VDRCONFDIR
VDR_HOST = localhost
VDR_PORT = 2001
VDRVFAT = 1
VIDEODIR = $VIDEODIR
ZEITRAHMEN = 1
" > /etc/vdradmin/vdradmind.conf
    fi
    chown -R $VDRUSER.$VDRGROUP /etc/vdradmin
    log "SUCCESS - $VERSION erstellt"
  else
    log "ERROR - $VERSION konnte nicht erstellt werden"
  fi
  ldconfig
}

# uninstall
function clean_util() {
  # uninstall vdradmin
  cd $SOURCEDIR/$LINK
  ./uninstall.sh

  # remove config
  rm -rf /etc/vdradmin

  # remove init script
  local AUTOSTART="off"
  make_autostart vdradmin-am
  rm -f /etc/init.d/vdradmin-am

  # remove source
  cd $SOURCEDIR
  rm -rf $LINK
  rm -rf $VERSION

  ldconfig
}

# test
function status_util() {
  if [ -f /usr/bin/vdradmind ]; then
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
