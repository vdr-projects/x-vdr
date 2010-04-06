#!/bin/sh

# Installation von vlc-0.9.8a auf sidux-2009-01.
#
# Damit alle notwendigen Pakete installiert sind,
# muss x-vdr/apt.sh vorher mindestens einmal gestartet werden.
#
# Anstatt 'checkinstall' ginge auch 'dpkg-buildpackage':
#    svn co svn://svn.debian.org/pkg-multimedia/videolan/vlc/debian debian &&
#    dpkg-buildpackage -rfakeroot -us -uc &&
# dazu muessen dann aber noch einige libs nach installiert werden.
#
# Marc Wernecke - www.zulu-entertainment.de
# 17.02.2009

# pre-install
apt-get update
apt-get -y --force-yes --purge remove libvlc0 vlc vlc-nox
apt-get -y --force-yes install libhal-dev libfribidi-dev libgcrypt-dev
apt-get -y --force-yes install libcddb2-dev libdvbpsi5-dev xulrunner-dev
apt-get -y --force-yes install liblivemedia-dev libpulse-dev

[ -f /root/vlc-0.9.8a.tar.bz2 ] ||
   wget --tries=2 http://download.videolan.org/pub/videolan/vlc/0.9.8a/vlc-0.9.8a.tar.bz2 --directory-prefix=/root

[ -f /root/vlc-0.9.8a.tar.bz2 ] || exit 1
[ -d /usr/local/src/vlc-0.9.8a ] && rm -rf /usr/local/src/vlc-0.9.8a
tar xjf /root/vlc-0.9.8a.tar.bz2 -C /usr/local/src

# install
cd /usr/local/src/vlc-0.9.8a

./configure --prefix=/usr \
  --disable-glx --disable-opengl \
  --enable-mozilla --enable-faad --enable-flac &&
make &&
checkinstall --fstrans=no --install=yes --pkgname=vlc --pkgversion "0.9.8a" --default &&

# create vlc-nox dummy package
echo "Section: misc
Priority: optional
Standards-Version: 3.6.2

Package: vlc-nox
Version: 0.9.8a-1
Maintainer: Musterman <Musterman@musterman.de>
Depends: vlc
Provides: vlc
Architecture: all
Description: vlc-nox dummy package
" > ./vlc-nox &&

equivs-build vlc-nox &&
dpkg -i vlc-nox_0.9.8a-1_all.deb &&

cp -f *.deb /root

