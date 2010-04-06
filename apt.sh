#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 24.03.2009

# defaults
HAVE_64bit=$(uname -m | grep x86_64)
install_usefull_stuff="off"
ffmpeg="off" # on=source und off=deb
libdvd="off" # on=source und off=deb
sources_list="/etc/apt/sources.list"

[ -f ./x-vdr.conf ] || exit 1
source ./x-vdr.conf
[ -f ./setup.conf ] && source ./setup.conf
source ./functions

[ "$1" = "--upgrade" ] && APT_UPGRADE="on"

KERNEL=`uname -r`
DIR=`pwd`
EXITCODE=0

# create error file
error_file="$SOURCEDIR/x-vdr/.error"
echo "apt.sh" > $error_file

# verify_input
COPYLIST=`verify_input "$COPYLIST"`
burn=`verify_input "$burn"`
coverviewer=`verify_input "$coverviewer"`
ffmpeg=`verify_input "$ffmpeg"`
mplayer=`verify_input "$mplayer"`
projectx=`verify_input "$projectx"`
xine_lib=`verify_input "$xine_lib"`

# parsix only
if [ "$LINUXVERSION" = "parsix" ] || [ -f /etc/parsix-version ]; then
  COPYLIST="off"
fi

# start
cd $SOURCEDIR
if [ ! -d $SOURCEDIR/x-vdr ]; then ln -vnfs $DIR x-vdr ; fi

if [ "$COPYLIST" = "on" ]; then
  [ -f "$sources_list" ] || echo "# $sources_list" > $sources_list

  if [ `grep -cw 'ubuntu' $sources_list` -gt 0 ] || [ "$LINUXVERSION" = "ubuntu" ]; then # ubuntu only
    LINUXVERSION="ubuntu"
    ubuntu_version="hardy"
    [ `grep -cw 'hardy'    $sources_list` -gt 0 ] && ubuntu_version="hardy"    && log "found ubuntu-${ubuntu_version}"
    [ `grep -cw 'intrepid' $sources_list` -gt 0 ] && ubuntu_version="intrepid" && log "found ubuntu-${ubuntu_version}"
    [ `grep -cw 'jaunty'   $sources_list` -gt 0 ] && ubuntu_version="jaunty"   && log "found ubuntu-${ubuntu_version}"

    medibuntu="deb http://de.packages.medibuntu.org/ $ubuntu_version free non-free"
    if [ `grep -cw "^deb http://.*.packages.medibuntu.org/ $ubuntu_version free non-free" $sources_list` -eq 0 ]; then
      log "adding '$medibuntu' to $sources_list"
      var=`grep -m 1 "deb http://.*.packages.medibuntu.org/ $ubuntu_version free non-free" $sources_list`
      if [ -n "$var" ]; then
        sed -i $sources_list -e s?"$var"?"$medibuntu"?g
      else
        echo "$medibuntu" >> $sources_list
        echo "" >> $sources_list
      fi
      wget -q http://de.packages.medibuntu.org/medibuntu-key.gpg -O- | apt-key add -
    fi

  else # debian, kanotix and sidux

    if [ "$LINUXVERSION" = "sidux" ]; then  #  && [ `grep -cw 'sidux' $sources_list` -gt 0 ]
      sources_list="/etc/apt/sources.list.d/debian.list"
      [ -f "$sources_list" ] || echo "# debian" > $sources_list
      debian_sid="deb http://ftp.de.debian.org/debian/ sid main contrib non-free"
      if [ `grep -cw "^deb http://ftp.*debian.org/debian/ sid main contrib non-free" $sources_list` -eq 0 ]; then
        var=`grep -m 1 "deb http://ftp.*debian.org/debian/ sid" $sources_list`
        if [ -n "$var" ]; then
          sed -i $sources_list -e s?"$var"?"$debian_sid"?g
        else
          echo "$debian_sid" >> $sources_list
          echo "" >> $sources_list
        fi
      fi

      sources_list="/etc/apt/sources.list.d/sidux.list"
      [ -f "$sources_list" ] || echo "# sidux" > $sources_list
      sidux_deb="deb http://sidux.com/debian/ sid main contrib non-free firmware fix.main fix.contrib fix.non-free"
      sidux_deb_src="deb-src http://sidux.com/debian/ sid main contrib non-free firmware fix.main fix.contrib fix.non-free"
      if [ `grep -cw "^$sidux_sid" $sources_list` -eq 0 ]; then
#        var=`grep -m 1 "deb.*http://sidux.com/debian/ sid" $sources_list`
#        if [ -n "$var" ]; then
#          sed -i $sources_list -e s?"$var"?"$sidux_sid"?g
#        else
#          echo "$sidux_sid" >> $sources_list
#        fi
        echo "$sidux_sid" >> $sources_list
        echo "#${sidux_deb_src}" >> $sources_list
        echo "" >> $sources_list
      fi
      sources_list="/etc/apt/sources.list.d/multimedia.list"
      [ -f "$sources_list" ] || echo "# debian-multimedia" > $sources_list
    fi

    # debian-multimedia > sources.list
    if [ `grep -cw 'debian-multimedia' $sources_list` -eq 0 ]; then
      echo "" >> $sources_list
      echo "# debian-multimedia" >> $sources_list
    fi

#    multi_etch="deb http://www.debian-multimedia.org etch main"
#    if [ `grep -cw "^$multi_etch" $sources_list` -eq 0 ]; then
#      var=`grep -m 1 "$multi_etch" $sources_list`
#      if [ -n "$var" ]; then
#        sed -i $sources_list -e s?"$var"?"$multi_etch"?g
#      else
#        echo "$multi_etch" >> $sources_list
#        echo "" >> $sources_list
#      fi
#    fi

    multi_sid="deb http://www.debian-multimedia.org sid main"
    if [ `grep -cw "^$multi_sid" $sources_list` -eq 0 ]; then
      var=`grep -m 1 "$multi_sid" $sources_list`
      if [ -n "$var" ]; then
        sed -i $sources_list -e s?"$var"?"$multi_sid"?g
      else
        echo "$multi_sid" >> $sources_list
        echo "" >> $sources_list
      fi
    fi

    # gpg keyserver
    key_list=`apt-key list`
    # debian
    if [ `grep -cw '^deb.*http://ftp.de.debian.org/debian' $sources_list` -gt 0 ]; then
      if [ `echo $key_list | grep -cw 6070D3A1` -eq 0 ]; then
        gpg --keyserver wwwkeys.eu.pgp.net --recv-keys 6070D3A1
        apt-key add /root/.gnupg/pubring.gpg
      fi
    fi
    # debian-multimedia
    if [ `grep -cw '^deb http://www.debian-multimedia.org' $sources_list` -gt 0 ]; then
      if [ `echo $key_list | grep -cw 1F41B907` -eq 0 ]; then
        gpg --keyserver wwwkeys.eu.pgp.net --recv-keys 1F41B907
        apt-key add /root/.gnupg/pubring.gpg
      fi
    fi
    # gpg-end
  fi
fi

cd $DIR


### update cache
apt-get update


### kick-list ->
if [ "$INSTALL_MODE" = "force" ]; then
  apt_remove "$(apt-cache search vdr | cut -d" " -f1 | grep ^vdr)"
  apt_remove "$(apt-cache search vdr | cut -d" " -f1 | grep [x\-]vdr)"
fi

apt_remove "$(apt-cache search vdr | cut -d" " -f1 | grep sidux)"

### get-list ->
apt_install "dialog xdialog rxvt"                                 # -> x-vdr

# debian
if [ "$LINUXVERSION" = "debian" ]; then
  apt_install "localepurge"
  apt_install "rcconf"
  apt_install "modconf"
  apt_install "alsa-base"                                         # -> bitstreamout
  apt_install "ssh ethtool etherwake wireless-tools pump"         # network-tools
  apt_install "ttf-bitstream-vera"
  apt_install "lynx unzip tofrodos"
  apt_install "shared-mime-info"                                  # -> xine-ui
fi

# sidux
#if [ "$LINUXVERSION" = "sidux" ]; then
#fi

# ubuntu
if [ "$LINUXVERSION" = "ubuntu" ]; then
  libdvd="on" # on=source und off=deb
fi

apt_install "linux-headers-`uname -r`"                            # -> module - dvb, dxr3, lirc ...
[ -L /usr/src/linux ] && rm -f /usr/src/linux
if [ ! -d /usr/src/linux ]; then
  cd /usr/src
  ln -vfs /usr/src/linux-headers-`uname -r` linux
  cd $DIR
fi

unfreeze_rc
apt_install "at"                                                  # -> system, vdr
freeze_rc

if [ "$projectx" = "on" ] ||  [ "$coverviewer" = "on" ] ; then    # -> projectx (java libs)
  apt_install "sun-java6-plugin"
  apt_install "libcommons-net-java"
  apt_remove  "sun-j2re1.4"
#  apt_install "libxp6"
#  apt_install "libxtst6"
fi

if [ -n "$HAVE_64bit" ]; then
  apt_install "w64codecs"                                         # -> mplayer, xine
else
  apt_install "w32codecs"                                         # -> mplayer, xine
fi

apt_install "mc"                                                  # -> x-vdr
apt_install "setserial"                                           # -> lirc
apt_install "dvb-utils"
apt_install "nvram-wakeup"                                        # -> system, vdr (optional)
apt_install "wakeonlan"                                           # -> system (optional)

apt_install "gcc g++"
apt_install "autoconf"                                            # -> system
apt_install "automake1.9"                                         # -> system
apt_install "fontconfig"                                          # -> system
apt_install "libtool"                                             # -> system
apt_install "libjpeg62-dev"                                       # -> system
apt_install "libcap-dev"                                          # -> system
apt_install "libc6 libc6-dev"                                     # -> system
apt_install "cvs"                                                 # -> x-vdr
apt_install "mercurial"                                           # -> x-vdr
apt_install "subversion"                                          # -> x-vdr
apt_install "git-core"                                            # -> x-vdr

apt_install "build-essential"                                     # -> x-vdr
apt_install "checkinstall"                                        # -> x-vdr
apt_install "yasm texi2html"
apt_install "equivs"                                              # -> x-vdr

apt_install "imagemagick"
apt_install "libmagick++9-dev"

apt_install "libmp3lame-dev"                                      # -> ffmpeg, mplayer
apt_install "libasound2-dev"                                      # -> lirc
apt_install "libflac-dev libflac++-dev libogg-dev"                # -> mplayer, xine  !!! zur Zeit nicht verfuegbar: liboggflac-dev
apt_install "libmad0-dev libtag1-dev libvorbis-dev libwrap0-dev"  # -> mp3, muggle, podcatcher
apt_install "libfaac-dev"                                         # -> ffmpeg-svn und ???
apt_install "libfaad-dev"                                         # -> ffmpeg-svn, xine ?
apt_install "libxvidcore4-dev"                                    # -> ffmpeg-svn
#apt_install "libdts-dev"                                          # -> now we use internal dts with xine-lib-hg

apt_install "libaa1 libaa1-dev libaa-bin libgtk2.0-dev libgtk2-perl"
apt_install "libogg-vorbis-header-pureperl-perl libvorbis-dev libvorbis0a libvorbisenc2"
apt_install "libtheora-dev"
apt_install "libfftw3-dev"                                        # -> span


# ffmpeg spezial
if [ "$ffmpeg" = "on" ]; then
  if [ "`apt_installed ffmpeg`" != "xvdr"  ]; then
    cd $SOURCEDIR/x-vdr/utilities/ffmpeg
    chmod 744 ./utilitie.sh
    log "Starte ffmpeg..."
    ./utilitie.sh || EXITCODE=1
  fi
else
  apt_install "ffmpeg"
  apt_install "libavcodec-dev libavutil-dev libpostproc-dev libavformat-dev libswscale-dev"
fi

# libdvd spezial
if [ "$libdvd" = "on" ]; then
  if [ "`apt_installed libdvdread4`" != "xvdr"  ]; then
    log "Starte dvdread..."
    cd $SOURCEDIR/x-vdr/utilities/libdvd
    chmod 744 ./utilitie-libdvdread.sh
    ./utilitie-libdvdread.sh
  fi

  if [ "`apt_installed libdvdnav4`" != "xvdr"  ]; then
    log "Starte dvdnav..."
    cd $SOURCEDIR/x-vdr/utilities/libdvd
    chmod 744 ./utilitie-libdvdnav.sh
    ./utilitie-libdvdnav.sh
  fi
else
  apt_install "libdvdread-dev libdvdnav-dev"
fi

#apt_install "transcode"

apt_install "liba52-0.7.4-dev vobcopy"
apt_install "mpeg2dec libmpeg2-4-dev"
apt_install "libfreetype6-dev" # freetype2
apt_install "libcompress-zlib-perl"
apt_install "dvd+rw-tools mkisofs"
apt_install "lame sox toolame"
apt_install "libfame-dev libmpeg3-dev"
apt_install "dvdauthor"
apt_install "imlib-base imlib11-dev libimlib2-dev" # imlib-progs
apt_install "libid3tag0-dev"                                      # -> mp3
apt_install "libsndfile1-dev nasm"                                # -> mp3
apt_install "mp3cd"                                               # -> music
apt_install "ripit id3 id3v2"                                     # -> ripit
apt_install "libevent-dev"
apt_install "netpbm"
apt_install "cddb"
apt_install "libcdio-dev"
apt_install "libcdio-paranoia-dev"                                # -> xine
apt_install "libdirectfb-dev libdfb++-dev"                        # -> softdevice
apt_install "libxv-dev libxvmc-dev"                               # -> softdevice
apt_install "libxt-dev"                                           # -> softdevice
apt_install "libxxf86vm-dev"                                      # -> softdevice

apt_install "libquicktime-dev"
apt_install "libmjpegtools-dev"
apt_install "mjpegtools"
apt_install "y4mscaler"

apt_install "sqlite3"                                             # -> muggle
apt_install "libsqlite3-dev"                                      # -> muggle
apt_install "ogmtools"                                            # -> vdrrip
apt_install "libgphoto2-2-dev"                                    # -> digicam
apt_install "libboost-dev libgd2-xpm-dev"                         # -> burn
#apt_install "libiax-dev"                                          # -> asterisk
[ "$mailbox" = "on" ] && apt_install "libc-client-dev"            # -> mailbox
apt_install "libcurl4-openssl-dev"                                # -> tvtv, rssreader, podcatcher
apt_install "libxml2-dev"                                         # -> vdrtvtime, podcatcher
apt_install "libxml++2.6-dev libsigc++-2.0-dev libglibmm-2.4-dev" # -> menuorg, podcatcher
apt_install "libxtst-dev"                                         # -> vdrtvtime
apt_install "libtntnet-dev"                                       # -> live
apt_install "libgtop2-dev"                                        # -> graphtft
apt_install "sharutils"                                           # -> burn-bc (snapshot)
apt_install "netcat"                                              # -> osdserver
apt_install "libhildonmime0"                                      # -> xine-lib / xine-ui (update-mime-database)
apt_install "libvcdinfo-dev"                                      # -> xine-lib (hg)
apt_install "libextractor-dev"                                    # -> xineliboutput
apt_install "libdbus-glib-1-dev"                                  # -> xineliboutput (cvs)
apt_install "libxslt1-dev"                                        # -> tvm2vdr
apt_install "input-utils"                                         # -> fuer Bert ;)
apt_install "libsox-fmt-all"                                      # -> SoX is the swiss army knife of sound processing.
apt_install "mp3gain"                                             # -> dvdconvert
#apt_install "mysql-server-5.0"                                    # -> xxv
#apt_install "libmysqlclient15-dev"                                # -> xxvautotimer
#apt_install "libpopt-dev libsdl-sound1.2-dev"

# usefull stuff
if [ "$install_usefull_stuff" = "on" ]; then

  if [ "`apt_installed kde`" != "not installed" ]; then
    apt_install "k9copy"
    apt_install "konq-plugins"
    apt_install "k3b libk3b3-extracodecs"
    apt_install "libgnome2-perl synaptic"
  fi

  if [ "`apt_installed nautilus`" != "not installed" ]; then
    apt_install "nautilus-gksu nautilus-image-converter nautilus-open-terminal"
    apt_install "nautilus-script-audio-convert nautilus-script-manager"
  fi

  apt_install "iceweasel iceweasel-l10n-de iceweasel-itsalltext"
  apt_install "flashplugin-nonfree"
  apt_install "fontforge fontforge-doc"
  apt_install "easytag"
  apt_install "vlc"
fi


# cdfs spezial
if [ ! -d "/usr/src/modules/cdfs" ]; then
  apt_install "cdfs-src"
  cd /usr/src
  tar xjf cdfs.tar.bz2
  cd /usr/src/modules/cdfs/2.6
  make
  make install
  mkdir /media/cdfs
fi

# vdr-burn / dvdconvert spezial
if [ "$burn" = "on" ] || [ "$dvdconvert" = "on" ]; then
  # vdrsync
  TEST=`which vdrsync.pl`
  if [ "$TEST" ]; then
    log "found $TEST"
  else
    cd $SOURCEDIR/x-vdr/utilities/vdrsync
    chmod 0744 ./utilitie-test.sh
    ./utilitie-test.sh
  fi

  # genindex
  TEST=`which genindex`
  if [ "$TEST" ]; then
    log "found $TEST"
  else
    cd $SOURCEDIR/x-vdr/utilities/genindex
    chmod 0744 ./utilitie-test.sh
    ./utilitie-test.sh
  fi

  # m2vrequantizer
  TEST=`which requant`
  if [ "$TEST" ]; then
    log "found $TEST"
  else
    cd $SOURCEDIR/x-vdr/utilities/m2vrequantizer
    chmod 0744 ./utilitie-test.sh
    ./utilitie-test.sh
  fi

  # tcmplex-panteltje
  TEST=`which tcmplex-panteltje`
  if [ "$TEST" ]; then
    log "found $TEST"
  else
    cd $SOURCEDIR/x-vdr/utilities/tcmplex_panteltje
    chmod 0744 ./utilitie-test.sh
    ./utilitie-test.sh
  fi
fi

echo ""
apt-get moo
echo ""

# timezone
dpkg-reconfigure tzdata

# final check
case $EXITCODE in
  0 ) log "SUCCESS - apt.sh" ;;
  * ) log "ERROR - apt.sh"; exit ;;
esac

# delete error file
[ -f $error_file ] && rm -f $error_file
exit 0
