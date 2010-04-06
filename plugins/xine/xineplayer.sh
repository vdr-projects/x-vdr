#!/bin/sh
#
# xineplayer.sh - 0.0.1
# Marc Wernecke - www.zulu-entertainment.de
# 28.09.2005
#
# This script is called from VDR to start xineplayer
#
# argument 1: the file to play
# argument 2: (optional) the phrase SLAVE if SlaveMode is enabled
# argument 3: (optional) the phrase AID x to select audio stream x

# Load defaults
. /etc/default/vdr

# Where to find xineplayer
XINEPLAYER="xineplayer"

# Where to find DVD/VCD dummy files? (just a fake and empty text file for the plugin)
DVDFiles="$MEDIADIR/DVD-VCD"

# What is your DVD-ROM device ?
DVD="/dev/dvd"

#####################

FILE=$1

if test \( "$FILE" == "$DVDFiles/DVD" -o "$FILE" == "$DVDFiles/VCD" \) -a -n "$DVDFiles" -a -n "$DVD"; then
	if test "$FILE" == "$DVDFiles/DVD"; then
		CMDLINE="$XINEPLAYER -dvd-device $DVD dvd://"
	fi
	if test "$FILE" == "$DVDFiles/VCD"; then
		CMDLINE="$XINEPLAYER -cdrom-device $DVD vcd://"
	fi
	unset FILE
elif test "${SUFFIX}" == ".cue"; then
	CMDLINE="$XINEPLAYER -vcd 2 -cuefile"
else
	CMDLINE="$XINEPLAYER $FILE"
fi

exec $CMDLINE
exit