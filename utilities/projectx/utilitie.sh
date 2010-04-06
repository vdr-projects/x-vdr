#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 24.03.2009

# projectx

source ./../../x-vdr.conf
source ./../../setup.conf
source ./../../functions

WEB="http://www.zulu-entertainment.de/files/projectx/ProjectX-0.90.4.tar.bz2"
VERSION="ProjectX-0.90.4"
LINK="ProjectX"

VAR=`basename $WEB`
DIR=`pwd`

# install
function make_util() {
  # java libs
  apt_install "sun-java6-plugin libcommons-net-java"
  apt_remove sun-j2re1.4

  # java bin  
  JAVA="/usr/lib/jvm/java-6-sun/jre/bin/java"
  [ ! -f $JAVA ] && JAVA=`which java`

  # projectx
  download_util
  extract_util

  # move dir
  mv -f $SOURCEDIR/$VERSION $PREFIX/bin/ProjectX

#  # commons-net
#  [ -f /usr/share/java/commons-net-1.3.0.jar ] && cp -f /usr/share/java/commons-net-1.3.0.jar $LINK/lib

  # projectx starter
  if [ -f $PREFIX/bin/ProjectX/ProjectX.jar ] && [ -f $JAVA ]; then
    {
      echo "#!/bin/sh"
      echo "exec $JAVA -jar $PREFIX/bin/ProjectX/ProjectX.jar"
    } > $PREFIX/bin/projectx
    chmod 755 $PREFIX/bin/projectx
  fi
}

# uninstall
function clean_util() {
  # remove script
  rm -f $PREFIX/bin/projectx

  # remove source
  rm -rf $PREFIX/bin/ProjectX
}

# test
function status_util() {
  if [ -f "$PREFIX/bin/ProjectX/ProjectX.jar" ]; then
#    [ -d $SOURCEDIR/$VERSION ] && echo "2" && return 0
#    echo "1"
    echo "2"
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
