#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 07.03.2009

# vdrfonts

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://andreas.vdr-developer.org/fonts/download/vdrsymbols-ttf-20080905.tgz"
VERSION="vdrsymbols-ttf-20080905"

VAR=`basename $WEB`
DIR=`pwd`

# install
function make_util() {
  download_util
  [ -d /usr/share/fonts/truetype/vdrsymbols ] && rm -rf /usr/share/fonts/truetype/vdrsymbols
  if echo "$FILES/utilities/$VAR" | grep "bz2$" - &>/dev/null; then
    if tar xjf "$FILES/utilities/$VAR" -C /usr/share/fonts/truetype; then
      log "extrahiere $VAR"
      return 0
    fi
  else
    if tar xzf "$FILES/utilities/$VAR" -C /usr/share/fonts/truetype ; then 
      log "extrahiere $VAR"
      return 0
    fi
  fi
  log "ERROR - $VERSION konnte nicht erstellt werden"
}

# uninstall
function clean_util() {
  [ -d /usr/share/fonts/truetype/vdrsymbols ] && rm -rf /usr/share/fonts/truetype/vdrsymbols
}

# test
function status_util() {
  [ -d /usr/share/fonts/truetype/vdrsymbols ] && echo "2" && return 0
  echo "0"
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
