#!/bin/sh
 
 # x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
 # von Marc Wernecke - www.zulu-entertainment.de
 # 20.08.2006
 #
 # vdr-control
 
 # defaults
 source ./../../x-vdr.conf
 source ./../../setup.conf
 source ./../../functions
 WEB="http://ricomp.de/vdr/vdr-control-0.0.2a.tgz"
 VERSION="control-0.0.2a"
 LINK="control"
 
 VAR=`basename $WEB`
 DIR=`pwd`
 
 # plugin entfernen
 function clean_plugin() {
 cd $SOURCEDIR/VDR/PLUGINS/src
 rm -rf $LINK*
 rm -f $VDRLIBDIR/libvdr-$LINK*
 log "cleaning $LINK"
 }
 
 # plugin installieren
 function install_plugin() {
 download_plugin
 extract_plugin
 cd $SOURCEDIR/VDR/PLUGINS/src
 rm -f $LINK
 ln -vfs $VERSION $LINK
 patch_plugin
 
 ## plugin specials - start ##
 
 ## plugin specials - ende ##
 }
 
 # plugin commands
 if [ $# \> 0 ]; then
 cmd=$1
 cmd_plugin
 else
 install_plugin
 log "install-plugin fuer $VERSION ist fertig"
 fi
 
 exit 0