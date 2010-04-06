#!/bin/sh
#
# mplayer.sh for x-vdr and xine
# Marc Wernecke - www.zulu-entertainment.de
# 28.09.2005
#
# This script is called from VDR to start mplayer
#
# argument 1: the file to play
# argument 2: (optional) the phrase SLAVE if SlaveMode is enabled
# argument 3: (optional) the phrase AID x to select audio stream x

# Where to find mplayer
MPLAYER="mplayer"

# mplayer options
OPTS="-fs -vo xv -ao oss -cache 4096"

# mplayer options for SlaveMode
SLAVE="-slave -quiet -nolirc"

# DVD-Device
DVD="/dev/dvd"

# What languages do your DVD's use ?
DVDLANG="de"

# extra DVD options
DVDOPTIONS="-af list=volume:volume=170"

####################################################################################

FILE=$1
type=`file "$FILE"`

while shift; do
  if [ "$1" = "SLAVE" ]; then
    sopt=$SLAVE
  elif [ "$1" = "AID" ]; then
    aopt="-aid $2"
    shift
  fi
done

CMDLINE="$MPLAYER $OPTS $sopt $aopt"

# get the file extension of the video
SUFFIX=$(echo -e "${FILE:$[${#FILE}-4]:4}" | tr [A-Z] [a-z])

# for debug only
echo "MPLayer command: $CMDLINE" 2>&1 |logger

case $SUFFIX in
	.iso ) DISPLAY=:0.0 $CMDLINE -alang $DVDLANG $DVDOPTIONS -dvd-device "$FILE" dvd:// 2>&1 |logger;;
	/dvd ) DISPLAY=:0.0 $CMDLINE -alang $DVDLANG $DVDOPTIONS -dvd-device $DVD dvd:// 2>&1 |logger ;;
	/vcd ) DISPLAY=:0.0 $CMDLINE -cdrom-device $DVD vcd:// 2>&1 |logger;;
	.cue ) DISPLAY=:0.0 $CMDLINE -cdrom-device $DVD cue://"$FILE":2  2>&1 |logger ;;
	* )    DISPLAY=:0.0 $CMDLINE "$FILE" 2>&1 |logger ;;
esac 

exit

####################################################################################
