#! /bin/bash

############################################################################
#    Copyright (C) 2004 by Ronny Frankowski (lini@lausitz.net)             #
#                        & AngieSoft (vdr@angiesoft.de)                    #
#                        & Matthias Appel (private_tweety@gmx.net)         #
#                                                                          #
#    This program is free software; you can redistribute it and#or modify  #
#    it under the terms of the GNU General Public License as published by  #
#    the Free Software Foundation; either version 2 of the License, or     #
#    (at your option) any later version.                                   #
#                                                                          #
#    This program is distributed in the hope that it will be useful,       #
#    but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#    GNU General Public License for more details.                          #
#                                                                          #
#    You should have received a copy of the GNU General Public License     #
#    along with this program; if not, write to the                         #
#    Free Software Foundation, Inc.,                                       #
#    59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
############################################################################


###########################################################################
# define some variables
###########################################################################

VERSION="1.0.2-xvdr"

[ -r /etc/default/vdr ] && . /etc/default/vdr
[ -d "$VIDEODIR" ]  || exit
[ -d "$DVDISODIR" ] || exit
[ -d "$VDRVARDIR" ] || exit
[ -d "$VDRBINDIR" ] || exit
[ -n "$DVDBURNER" ] || exit

VIDEODIR="$VIDEODIR"			# video directory of vdr
ISODIR="$DVDISODIR"			# dir for the isofiles
WORKDIR="$VDRVARDIR/dvdconvert/dvd2dvd"	# working directory of dvd2dvd
DVD_DEVICE="$DVDBURNER"			# dvd device

LANGUAGE="de"				# select preferred language
					# "de", "en"

RECORDING_LIFETIME=99			# lifetime from 00 to 99

DVD_SIZE=4300000000			# DVD Size 4,3GB

#TITLE_MIN_LENGTH=60			# mimimun length in sec for
					# a title on a DVD to be
					# considered for conversion

PRIO=19					# priority from 1 to 19
SLEEPTIME=10				# wait for user action
VERBOSE=1				# be verbose - 0: off, 1: on
DEBUG=2					# debug info - 0: off, 1-3: level
FORCE=0					# force exec - 0: off, 1: on (erzwingen)
CLEAN=1					# clean dirs - 0: off, 1: on (abschliesendes loeschen)
REMOVE=1				# remove tmp file - 0: off, 1: on (temp. loeschen im Betrieb)

REMOVE_ISO=0				# remove iso file - 0: off, 1: on
BURN=0					# burn a dvd - 0: off, 1: on
RW_FORMAT=0				# format a dvd+rw or dvd-rw disk - 0: off, 1: on

OSDINFO=1				# svdrpsend - 0: off, 1: on

A52DEC_GAIN="+5.0"			# add gain in decibels
CREATE_MARKS=0				# create a marks.vdr for vdr - 0: off, 1: on


###########################################################################
# define required tools
###########################################################################

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/X11R6/bin:~/bin

SVDRPSEND_PL="$VDRBINDIR/svdrpsend.pl"

VOBCOPY_BIN=vobcopy
EJECT_BIN=eject
TCPROBE_BIN=tcprobe
TCCAT_BIN=tccat
TCEXTRACT_BIN=tcextract
TCDEMUX_BIN=tcdemux

A52DEC_BIN=a52dec
TOOLAME_BIN=toolame
MP2ENC_BIN=mp2enc

JAVA_BIN=java
PROJECTX_JAR=$PROJECTX_HOME/ProjectX.jar
[ ! -f "$PROJECTX_JAR" ] && PROJECTX_JAR=/usr/bin/ProjectX/ProjectX.jar
PROJECTX_INI=$PROJECTX_HOME/ProjectX.ini
[ ! -f "$PROJECTX_INI" ] && PROJECTX_JAR=/usr/bin/ProjectX/ProjectX.ini
XVFB_BIN=Xvfb

TCMPLEX_BIN=tcmplex
TCMPLEX_PANTELTJE_BIN=tcmplex-panteltje
MPLEX_BIN=mplex

REQUANT_BIN=tcrequant

DVDAUTHOR_BIN=dvdauthor

MKISOFS_BIN=mkisofs

DVDSTATUS_BIN=dvd+rw-mediainfo
DVDRECORD_BIN=dvdrecord
GROWISOFS_BIN=growisofs

DVDRECORD_OPT_1="-dao blank=fast"
DVDFORMAT_BIN="dvd+rw-format -f"
DVDRECORD_OPT_2="-dao driveropts=burnfree"
DVDFORMAT_OPT="-Z"

LOGDIR="$VDRVARDIR/dvdconvert/log"
LOGFILE=$LOGDIR/dvd2dvd.log
LOCKFILE=$LOGDIR/dvd2dvd.LOCK


###########################################################################
# print usage information
###########################################################################

usage() {
test -n "$1" && echo "${RED}    Error:    $1${NORMAL}" && echo
echo "    DVD2DVD   Version ${MAGENTA}$VERSION${NORMAL}"
echo
echo "    ${CYAN}Usage:    ${GREEN}$0${NORMAL}"
echo "    ${CYAN}   or:    ${GREEN}$0${NORMAL} <action> [options]"
echo
echo "    DVD2DVD is intended to convert the main movie of a DVD into"
echo "    a VDR recoring. If required the main movie will be demuxed"
echo "    transcoded and remuxed again."
echo
echo "    ${CYAN}Actions:${NORMAL}"
echo
echo "${GREEN}    all${NORMAL}"
echo "              Do all steps of the following"
echo "${GREEN}    copy${NORMAL}"
echo "              Copy the main movie to disk"
echo "${GREEN}    demux${NORMAL}"
echo "              Demultiplex the main movie in mpv and ac3"
echo "${GREEN}    encode${NORMAL}"
echo "              Encode ac3 to mp2"
echo "${GREEN}    reqant${NORMAL}"
echo "              Verkleinern des Videofile"
echo "${GREEN}    mplex${NORMAL}"
echo "              Multiplex the parts to a VDR recording"
echo "${GREEN}    dvdauthor${NORMAL}"
echo "              Create a dvd structur"
echo "${GREEN}    iso${NORMAL}"
echo "              Create a iso file"
echo "${GREEN}    burn${NORMAL}"
echo "              Burn the DVD"
echo "${GREEN}    move${NORMAL}"
echo "              Move recording to video directory"
echo
echo "    ${CYAN}Options:${NORMAL}"
echo
echo "${GREEN}    -i | --device ${MAGENTA}<device>${NORMAL}"
echo "              Read DVD structure from this device"
echo "${GREEN}    -o ${MAGENTA}<dirname>${NORMAL}"
echo "              Write output into this video directory"
echo "${GREEN}    -s ${MAGENTA}<dirname>${NORMAL}"
echo "              Write iso file into this directory"
echo "${GREEN}    -w ${MAGENTA}<dirname>${NORMAL}"
echo "              Use working directory as base for temp directory"
echo "${GREEN}    -t ${MAGENTA}<dirname>${NORMAL}"
echo "              Use temp directory for temporary files"
echo "${GREEN}    --preferred-language ${MAGENTA}<language>${NORMAL}"
echo "              Choose preferred language for messages"
echo "              and the main movie (default is \"de\")"
echo "${GREEN}    --no-osd-info${NORMAL}"
echo "              Don't send messages to the OSD of VDR"
echo "${GREEN}    --set-title ${MAGENTA}<string>${NORMAL}"
echo "              Set title of main movie to <string>"
echo "${GREEN}    --read-title-num ${MAGENTA}<number>${NORMAL}"
echo "              Read specific title set (1-99)"
echo "${GREEN}    --use-tcextract${NORMAL}"
echo "              Demux the main movie with tcextract (default)"
echo "${GREEN}    --use-projectX${NORMAL}"
echo "              Demux the main movie with projectX."
echo "              Ensure to have a X server running"
echo "${GREEN}    --projectX-ini ${MAGENTA}<filename>${NORMAL}"
echo "              Use this X.ini for projectX"
echo "${GREEN}    --use-Xvfb | --without-X${NORMAL}"
echo "              Start a virtual X Server with Xvfb"
echo "${GREEN}    --add-gain ${MAGENTA}<string>${NORMAL}"
echo "              Add gain to mp2 audio (-96.0 to +96.0)"
echo "${GREEN}    --use-mp2enc${NORMAL}"
echo "              Encode the audio track with mp2enc"
echo "${GREEN}    --use-toolame${NORMAL}"
echo "              Encode the audio track with toolame (default)"
echo "${GREEN}    --use-mp3gain${NORMAL}"
echo "              Normalize ac3 (time consuming)"
echo "${GREEN}    --use-tcmplex${NORMAL}"
echo "              Remux with tcmplex (default)"
echo "${GREEN}    --use-tcmplex-panteltje${NORMAL}"
echo "              Remux with tcmplex-panteltje"
echo "${GREEN}    --use-mplex${NORMAL}"
echo "              Remux with mplex"
echo "${GREEN}    --no-burn${NORMAL}"
echo "              No burn a DVD"
echo "${GREEN}    --no-rw-formatburn${NORMAL}"
echo "              No format a DVD+RW"
echo "${GREEN}    --force${NORMAL}"
echo "              Force execution of <action>"
echo "${GREEN}    --verbose${NORMAL}"
echo "              Turns verbosity on"
echo "${GREEN}    -V | --version${NORMAL}"
echo "              Print version information and exit"
echo "${GREEN}    --all-versions${NORMAL}"
echo "              Print version information of most used tools"
echo "${GREEN}    -h | -? | --help${NORMAL}"
echo "              Print this usage information"
exit 1
}

###########################################################################
# set color parameters
###########################################################################

# ANSI COLORS
CRE="
[K"
NORMAL="[0;39m"
# RED: Failure or error message
RED="[1;31m"
# GREEN: Success message
GREEN="[1;32m"
# YELLOW: Descriptions
YELLOW="[1;33m"
# BLUE: System messages
BLUE="[1;34m"
# MAGENTA: Found devices or drivers (pink)
MAGENTA="[1;35m"
# CYAN: Questions (hellblau)
CYAN="[1;36m"
# BOLD WHITE: Hint
WHITE="[1;37m"

###########################################################################
# check for given parameters
###########################################################################

case $DEBUG in
    1) ;;
    2) set -x ;;
    3) set -xv ;;
    *) LOGFILE=/dev/null ;;
esac

ACTION="all"
OPTIONS=$@
TEMPDIR=""
LANGUAGES=("de" "en")
TITLE=""
TITLENUM="AUTO"		# AUTO = vobcopy-test; MAX = max. Frames; 1,2,3... DVD-Title 
RECORDING=""
AUDIOTRACK=-1
AUDIOFORMAT=""
TCEXTRACTOPTAUDIO=""
WITHOUT_X=1
AC3_TRACK=1			

GETTITLE_TOOLS=("user-input" "vobcopy")
COPY_TOOLS=("tccat")
DEMUX_TOOLS=("tcextract" "projectX")
ENCODE_TOOLS=("mp2enc" "toolame")
MPLEX_TOOLS=("tcmplex" "tcmplex-panteltje" "mplex")

ACTION_GETTITLE=${GETTITLE_TOOLS[1]}
ACTION_COPY=${COPY_TOOLS[0]}
ACTION_DEMUX=${DEMUX_TOOLS[0]}
ACTION_ENCODE=${ENCODE_TOOLS[0]}
ACTION_MPLEX=${MPLEX_TOOLS[1]}

while [ $# -gt 0 ]; do
    case $1 in
	all|gettitle|copy|demux|encode|requant|mplex|dvdauthor|iso|burn|move)
	    ACTION="$1"
	    ;;
	-i|--device)
	    [ -b "$2" ] || usage "${RED}unknown device ${MAGENTA}'$2'${NORMAL}"
	    DVD_DEVICE="$2"
	    shift
	    ;;
	-o)
	    [ -d "$2" ] || usage "${RED}missing directory ${MAGENTA}'$2'${NORMAL}"
	    VIDEODIR="$2"
            shift
	    ;;
	-s)
	    [ -d "$2" ] || usage "${RED}missing directory ${MAGENTA}'$2'${NORMAL}"
	    ISODIR="$2"
            shift
	    ;;
	-w)
	    [ -d "$2" ] || usage "${RED}missing directory ${MAGENTA}'$2'${NORMAL}"
	    WORKDIR="$2"
            shift
	    ;;
	-t)
	    [ -d "$2" ] || usage "${RED}missing directory ${MAGENTA}'$2'${NORMAL}"
	    TEMPDIR=`echo $2 | sed "s/\/$//"`
            shift
	    ;;
	--preferred-language)
	    [ $2 = "" ] || usage "${RED}missing language${NORMAL}"
	    LANGUAGE=$2
	    shift
	    ;;
	--no-osd-info)
	    OSDINFO=0
	    ;;
	--set-title)
	    TITLE=`echo $2 | sed "s/[^a-zA-Z0-9???????/:.#'&_-]/_/g"`
	    ACTION_GETTITLE=${GETTITLE_TOOLS[0]}
	    shift
	    ;;
	--read-title-num)
#	    [ $2 -ge 1 -a $2 -le 99 ] || usage "${RED}invalid title number ${MAGENTA}'$2'${NORMAL}"
	    TITLENUM=$2
	    shift
	    ;;
	--use-tcextract)
	    ACTION_DEMUX=${DEMUX_TOOLS[0]}
	    ;;
	--use-projectX)
	    ACTION_DEMUX=${DEMUX_TOOLS[1]}
	    ;;
	--projectX-ini)
	    [ -e "$2" ] || usage "${RED}missing file ${MAGENTA}'$2'${NORMAL}"
	    PROJECTX_INI="$2"
            shift
	    ;;
	--use-Xvfb|--without-X)
	    WITHOUT_X=0
	    ;;
	--add-gain)
	    [ `echo $2 | \\
		grep -c "[+-][[:digit:]]\{1,2\}\.[[:digit:]]"` -eq 1 ] || \
		usage "${RED}invalid gain ${MAGENTA}'$2'${NORMAL}"
	    A52DEC_GAIN="$2"
	    shift
	    ;;
	--use-mp2enc)
	    ACTION_ENCODE=${ENCODE_TOOLS[0]}
	    ;;
	--use-toolame)
	    ACTION_ENCODE=${ENCODE_TOOLS[1]}
	    ;;
	--use-tcmplex)
	    ACTION_MPLEX=${MPLEX_TOOLS[0]}
	    ;;
	--use-tcmplex-panteltje)
	    ACTION_MPLEX=${MPLEX_TOOLS[1]}
	    ;;
	--use-mplex)
	    ACTION_MPLEX=${MPLEX_TOOLS[2]}
	    ;;
	--remove-iso)
	    REMOVE_ISO=1
	    ;;
	--no-burn)
	    BURN=0
	    ;;
	--no-rw-format)
	    RW_FORMAT=0
	    ;;
	--force)
	    FORCE=1
	    ;;
	--clean)
	    CLEAN=1
	    ;;
	--verbose)
	    VERBOSE=1
	    ;;
	-V|--version)
	    echo "${GREEN}$0   ${MAGENTA}Version $VERSION${NORMAL}"
	    exit 1
	    ;;
	--all-versions)
	    echo "${GREEN}$0   ${MAGENTA}Version $VERSION${NORMAL}"
	    echo
	    $VOBCOPY_BIN --version
	    $TCPROBE_BIN -v
	    $TCCAT_BIN -v
	    $TCEXTRACT_BIN -v
	    $TCDEMUX_BIN -v
	    echo
	    $A52DEC_BIN - 2>&1|grep a52dec
	    $TOOLAME_BIN --version 2>&1|grep version
	    echo
	    $JAVA_BIN -version
	    echo
	    $MPLEX_BIN -? 2>&1|grep version
	    $TCMPLEX_BIN -v
	    $TCMPLEX_PANTELTJE_BIN -v
	    echo
	    $MKISOFS_BIN -version
	    echo
	    $GROWISOFS_BIN -version 2>&1|grep version
	    $DVDRECORD_BIN -version
	    echo
	    exit 1
	    ;;
	-h|-?|--help)
	    usage
	    ;;
	*)
	    usage "${RED}unknown option ${MAGENTA}'$1'${NORMAL}" ;;
    esac
    shift
done

[ -f "$DVD2DVD_CONF" ] && . "$DVD2DVD_CONF"


###########################################################################
# translation tables for user messages
###########################################################################

LNG=0
for i in 0 1 ; do
    [ $LANGUAGE = ${LANGUAGES[$i]} ] && LNG=$i
done

MESG_01=( \
"Bitte die zu kopierende DVD einlegen" \
"please insert DVD" \
)

MESG_02=( \
"Keine DVD im Laufwerk erkannt" \
"DVD not found" \
)

MESG_03=( \
"Kopiere DVD auf Disk" \
"Copy DVD to disk" \
)

MESG_04=( \
"Videospur nicht gefunden - Abbruch" \
"main movie not found - exiting" \
)

MESG_05=( \
"Tonspur '$LANGUAGE' nicht gefunden - Abbruch" \
"Audio track '$LANGUAGE' not found - exiting" \
)

MESG_06=( \
"Kein unterstuetztes Audioformat auf der DVD gefunden - Abbruch" \
"no supported audio format found - exiting" \
)

MESG_07=( \
"Kopieren der DVD gescheitert - Abbruch" \
"copying of main movie failed - exiting" \
)

MESG_08=( \
"DVD auslesen beendet, bitte DVD entnehmen" \
"main movie successfully read, please remove DVD" \
)

MESG_09=( \
"Fehler bei der Umwandlung der DVD-Daten - Abbruch" \
"failed to transcode the main movie - exiting" \
)

MESG_10=( \
"DVD Daten werden mit '$ACTION_DEMUX' bearbeitet" \
"" \
)

MESG_11=( \
"DVD Daten werden mit '$ACTION_MPLEX' bearbeitet" \
"" \
)

MESG_12=( \
"DVD Daten werden mit '$REQUANT_BIN' verkleinert" \
"" \
)

MESG_13=( \
"DVD Daten werden auf DVD gebrannt" \
"" \
)

MESG_14=( \
"Alle temp. Daten geloescht" \
"" \
)

MESG_15=( \
"Daten befinden sich in ${ISODIR}" \
"" \
)

MESG_16=( \
"!!! GRATULATION , FERTIG  !!!" \
"" \
)

MESG_17=( \
"DVD Daten werden mit '$DVDAUTHOR_BIN' bearbeitet" \
"" \
)

MESG_18=( \
"DVD Daten werden mit '$MKISOFS_BIN' bearbeitet" \
"" \
)

MESG_19=( \
"DVD-Rohling fuer Brennvorgang einlegen" \
"" \
)

MESG_20=( \
"DVD-RW Medium wird geloescht" \
"" \
)

MESG_21=( \
"DVD wird geschrieben" \
"" \
)

MESG_22=( \
"DVD Schreibvorgang beendet, DVD entnehmen" \
"" \
)

MESG_23=( \
"DVD Schreibvorgang fehlgeschlagen, DVD entnehmen" \
"" \
)

MESG_30=( \
"textutils Fehler, update dein coreutils" \
"error textutils, upgrade your coreutils" \
)

###########################################################################
# prepare to run
###########################################################################

d2v_error () {
    echo "${RED}ERROR: ${MAGENTA}$1${NORMAL}"
    $EJECT_BIN $DVD_DEVICE
    exit 255
}


d2v_log () {
    [ $VERBOSE -eq 1 -o "$2" = "force" ] && echo "`date +"%T"`: $1"
    echo "`date +"%T"`: $1" >> $LOGFILE
}


d2v_log_separator () {
    d2v_log "---------------------------------------------------------------"
}


d2v_log_force () {
    d2v_log "$1" force
}


d2v_mesg () {
    if [ $OSDINFO -eq 1 ] ; then
	d2v_log "$SVDRPSEND_PL MESG $1"
	$SVDRPSEND_PL MESG "$1" >> $LOGFILE
    fi
}

if [ -e $LOCKFILE ] ; then
    if [ $FORCE -eq 1 ] ; then
	rm -f $LOCKFILE
    else
    PIDID=`cat $LOCKFILE`
    RUNCHECK=`ps $PIDID | grep 'dvd2' | wc -l`
	    if [ $RUNCHECK -eq 0 ];  then
	    	rm -f $LOCKFILE
	        d2v_log "dvd2dvd is not active, remove lockfile done"
	    else
    	    d2v_error "$0 is already running"
    	    fi
    fi
fi
                                                    
echo "$0 $OPTIONS" > $LOGFILE || d2v_error "${RED}Cannot create \$LOGFILE ${MAGENTA}'$LOGFILE'${NORMAL}"
echo $$ > $LOCKFILE || d2v_error "${RED}Cannot create \$LOCKFILE ${MAGENTA}'$LOCKFILE'${NORMAL}"

d2v_log_separator
d2v_log_force START

[ -d $VIDEODIR ] || d2v_error "${RED}\$VIDEODIR ${MAGENTA}'$VIDEODIR' ${RED}not found${NORMAL}"
    VIDEODIR=`echo $VIDEODIR | sed "s/\/$//"`
[ -d $WORKDIR ] || d2v_error "${RED}\$WORKDIR ${MAGENTA}'$WORKDIR' ${RED}not found${NORMAL}"
    WORKDIR=`echo $WORKDIR | sed "s/\/$//"`
[ -b $DVD_DEVICE ] || d2v_error "${RED}\$DVD_DEVICE ${MAGENTA}'$DVD_DEVICE' ${RED}not found${NORMAL}"

[ $PRIO -ge 1 -a $PRIO -le 19 ] || \
    d2v_error "${RED}\$PRIO ${MAGENTA}$PRIO ${RED}out of range${NORMAL}"
[ $VERBOSE -ge 0 -a $VERBOSE -le 1 ] || \
    d2v_error "${RED}\$VERBOSE ${MAGENTA}$VERBOSE ${RED}out of range${NORMAL}"

###########################################################################
# check the temp directory
###########################################################################

d2v_log_separator
d2v_log_force "checking the temp directory"

if [ $ACTION = "all" -a -z "$TEMPDIR" ] ; then

    TEMPDIR=`mktemp -dp ${WORKDIR}`
    TEMPDIR_ISO=`mktemp -dp ${TEMPDIR}`

    d2v_log "\$TEMPDIR='$TEMPDIR' and \$TEMPDIR_ISO='$TEMPDIR_ISO' created"

elif [ $ACTION != "all" -a -z "$TEMPDIR" ] ; then
    
    HELP="`echo && echo \$\> ls -d1 ${WORKDIR} && ls -d1 ${WORKDIR}/tmp.* 2> /dev/null`"
    [ `ls -d1 ${WORKDIR}/tmp.* 2> /dev/null | wc -l` -ne 1 ] && d2v_error "${RED}no unique temp directory found ${MAGENTA}$HELP${NORMAL}"

    TEMPDIR=`ls -d1 ${WORKDIR}/tmp.* | head -n 1`
    TEMPDIR_ISO=`ls -d1 ${TEMPDIR}/tmp.* | head -n 1`

    d2v_log "\$TEMPDIR='$TEMPDIR' and \$TEMPDIR_ISO='$TEMPDIR_ISO' used"
else
    d2v_log "\$TEMPDIR='$TEMPDIR' and \$TEMPDIR_ISO='$TEMPDIR_ISO' used"
fi



###########################################################################
# read and write global variables to disk
###########################################################################

VARIABLES="TITLE RECORDING TITLENUM AUDIOTRACK AUDIOFORMAT TCEXTRACTOPTAUDIO"

readvars () {
    local FILE=${TEMPDIR}/variables.info

    if [ -f $FILE ] ; then
	d2v_log_separator
	d2v_log_force "reading file '$FILE'"

	for i in $VARIABLES ; do
	    if [ "$i" != "TITLE" -o "$TITLE" = "" ] ; then
		eval $i=\"`grep "^$i=" $FILE | awk -F = '{print $2}'`\"
		eval d2v_log \"\\\$$i=\'$`echo $i`\'\"
	    fi
	done
	fi
}

writevars () {
    local FILE=${TEMPDIR}/variables.info

    if [ "$TITLE" != "" -a "$RECORDING" != "" ] ; then
	d2v_log_separator
	d2v_log_force "writing file '$FILE'"

	echo "LASTRUN=`date +"%Y-%m-%d %T"`" > $FILE || \
	    d2v_error "${RED}Cannot create file ${MAGENTA}'$FILE'${NORMAL}"

	for i in $VARIABLES ; do
	    eval echo "$i=$`echo $i`" >> $FILE
	done
    fi
}


###########################################################################
# gettitle of the main movie
###########################################################################

gettitle () {
    d2v_log_separator
    d2v_log_force \
	"using '$ACTION_GETTITLE' to get the title of the main movie"

    if [ "$TITLE" = "" -o "$RECORDING" = "" -o $FORCE -eq 1 ] ; then

	# insert DVD and do some checks
	d2v_mesg "${MESG_01[$LNG]}"
	$EJECT_BIN $DVD_DEVICE
	sleep $SLEEPTIME

	local DVDSTATUS="1"
	while [ "$DVDSTATUS" -gt 0 ] ; do
	    $TCPROBE_BIN -i $DVD_DEVICE -H 10 >> $LOGFILE 2>&1> /dev/null
	    DVDSTATUS=$?
		if [ $DVDSTATUS -gt 0 ]; then
		    d2v_mesg "${MESG_02[$LNG]}"
		    # insert DVD
		    d2v_mesg "${MESG_01[$LNG]}"
		    $EJECT_BIN $DVD_DEVICE
		    sleep $SLEEPTIME
		fi
	done

	case $ACTION_GETTITLE in
	    ${GETTITLE_TOOLS[0]})
		;;
	    ${GETTITLE_TOOLS[1]})
		d2v_log "`echo && echo \$\> $VOBCOPY_BIN -i $DVD_DEVICE \
		    -v -v -I -L ${TEMPDIR} 2\> /dev/null`"
		$VOBCOPY_BIN -i $DVD_DEVICE -v -v -I \
		    -L ${TEMPDIR} 2> /dev/null && \
		TITLE=`cat ${TEMPDIR}/vobcopy_*.log | \
		    grep 'Name of the dvd' | head -n 1 | awk '{print $6}'` && \
		cat ${TEMPDIR}/vobcopy_*.log >> $LOGFILE
		if [ $TITLENUM = "AUTO" ] ; then
			TITLENUM=`cat ${TEMPDIR}/vobcopy_*.log | \
			grep 'Using Title' | head -n 1 | awk '{print $4}'`
		fi
		;;
	esac

	d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"

	TITLE=`echo $TITLE | sed "s/[^a-zA-Z0-9???????/:.#'&_-]/_/g"`
	[ `echo $TITLE | wc -m` -le 2 ] && TITLE="DVD`date +%Y-%m-%d-%M-%H`"

	RECORDING="`date +%Y-%m-%d.%H.%M`"
    fi

    d2v_log_force "\$TITLE='$TITLE'"
    d2v_log_force "\$TITLENUM='$TITLENUM'"
    d2v_log_force "\$RECORDING='$RECORDING'"
}


###########################################################################
# test for the main movie
###########################################################################

test () {
    d2v_log_separator
    d2v_log_force \
	"using 'tcprobe' to test for the main movie"

    if [ ! -f ${TEMPDIR}/001.vob -o $FORCE -eq 1 -o \
	    $AUDIOTRACK -lt 0 -o "$AUDIOFORMAT" = "" -o \
	    "$TCEXTRACTOPTAUDIO" = "" ] ; then

	# find main movie
	local MAX_TITLENUM=0

	d2v_log "`echo && echo \$\> $TCPROBE_BIN -H 0 \
	    -i $DVD_DEVICE 2\>\&1 \| grep 'title 1/' \| awk '{print $5}'`"

	MAX_TITLENUM=`$TCPROBE_BIN -H 0 -i $DVD_DEVICE 2>&1 | \
			  grep 'title 1/' | awk '{print $5}'`

	if [ $MAX_TITLENUM = 0 ] ; then
	    d2v_mesg "${MESG_04[$LNG]}"
	    #$TCPROBE_BIN -H 0 -i $DVD_DEVICE 2>&1 >> $LOGFILE
	    cp $LOGFILE ${TEMPDIR}/$TITLE.log
	    d2v_error "${RED}exiting${NORMAL}"
	fi

	d2v_log "\$MAX_TITLENUM='$MAX_TITLENUM'"

	local i=0
	local FRAMES=0
	local MAX_FRAMES=0

	if [ $TITLENUM = "MAX" ] ; then
	    while [ "$i" -lt $MAX_TITLENUM ] ; do
		i=$((i+1))
		FRAMES=`$TCPROBE_BIN -i $DVD_DEVICE -H 10 -T $i \
			2>/dev/null | grep 'frames' | awk '{print $3}'`
		[ -z $FRAMES ] && FRAMES="0"
		if [ $FRAMES -gt $MAX_FRAMES ] ; then
			if [ $FRAMES -gt $((${TITLE_MIN_LENGTH}*25)) ]; then
		    		TITLENUM="$i"
		    		MAX_FRAMES="$FRAMES"
		    	fi
		fi
	    done
	fi

	d2v_log "\$MAX_FRAMES='$MAX_FRAMES'"
	if [ $TITLENUM = "MAX" ]; then
	    d2v_mesg "${MESG_04[$LNG]}"
	    $TCPROBE_BIN -H 0 -i $DVD_DEVICE 2>&1 >> $LOGFILE
	    cp $LOGFILE ${TEMPDIR}/$TITLE.log
	    d2v_error "${RED}exiting${NORMAL}"
	fi

	d2v_log "\$TITLENUM='$TITLENUM'"

	# create the marks.vdr
	if [ $CREATE_MARKS -eq 1 ]; then
	d2v_log "`echo && echo \$\> $TCPROBE_BIN -i $DVD_DEVICE -H 10 \
	    -T $TITLENUM 2\>\&1 \| grep Chapter \| cut -d \\\" \\\" -f 4 \
	    \> ${TEMPDIR}/marks.vdr`"
	$TCPROBE_BIN -i $DVD_DEVICE -H 10 -T $TITLENUM 2>&1 | \
	    grep Chapter | cut -d " " -f 4 > ${TEMPDIR}/marks.vdr
	fi

	# read audio track
	local AUDIOTYPE=""
	local AUDIOTYPELINES=0
	local AUDIOFORMATLINES=0

	d2v_log "`echo && echo \$\> $TCPROBE_BIN -i $DVD_DEVICE -H 10 \
	    -T $TITLENUM 2\> /dev/null \| grep dvd_reader.c \| grep kHz \| \
	    cat -b - \> ${TEMPDIR}/transcode-audio.log`"
	$TCPROBE_BIN -i $DVD_DEVICE -H 10 -T $TITLENUM 2> /dev/null | \
	    grep dvd_reader.c | \
	    grep kHz | cat -b - > ${TEMPDIR}/transcode-audio.log

	d2v_log "`echo && echo \$\> $TCPROBE_BIN -i $DVD_DEVICE -H 10 \
	    -T $TITLENUM 2\> /dev/null \| grep "audio track:" \
	    cat -b - \> ${TEMPDIR}/transcode-audio2.log`"
	$TCPROBE_BIN -i $DVD_DEVICE -H 10 -T $TITLENUM 2> /dev/null | \
	    grep "audio track:" | cat -b - > ${TEMPDIR}/transcode-audio2.log

	AUDIOTRACK=`cat ${TEMPDIR}/transcode-audio.log | \
	grep -n " "$LANGUAGE" " | grep "ac3" | head -n 1 | \
	awk '{print (($1-1))}'`

	if [ -z $AUDIOTRACK ] ; then
		AUDIOTRACK=`cat ${TEMPDIR}/transcode-audio.log | grep -n " "$LANGUAGE" " | \
		head -n 1 | awk '{print (($1-1))}'`
		if [ -z $AUDIOTRACK ] ; then
			AUDIOTRACK=-1
		fi
	fi

	AUDIOTYPE=`cat ${TEMPDIR}/transcode-audio.log | \
	    grep " "$LANGUAGE" " | head -n 1 | awk '{print $3}'`
	AUDIOTYPELINES=`cat ${TEMPDIR}/transcode-audio.log | \
	    grep " "$LANGUAGE" " | head -n 1 | awk '{print $3}' | \
	    wc -m | awk '{print $1}'`
	AUDIOFORMATLINES=`cat ${TEMPDIR}/transcode-audio2.log | \
	    grep "0x55"| head -n 1 | wc -m | awk '{print $1}'`
	TRANSCODE_AUDIO=`cat ${TEMPDIR}/transcode-audio.log`
	TRANSCODE_AUDIO2=`cat ${TEMPDIR}/transcode-audio2.log`

	if [ -z $AUDIOTYPELINES ] ; then
	    d2v_mesg "${MESG_30[$LNG]}"
	    $TRANSCODE_AUDIO >> $LOGFILE
	    $TRANSCODE_AUDIO2 >> $LOGFILE
	    cp $LOGFILE ${TEMPDIR}/$TITLE.log
	    d2v_error "${RED}exiting${NORMAL}"
	fi
	
	if [ $AUDIOTYPELINES -eq 0 ] ; then
	    d2v_mesg "${MESG_05[$LNG]}"
	    $TRANSCODE_AUDIO >> $LOGFILE
	    $TRANSCODE_AUDIO2 >> $LOGFILE
	    cp $LOGFILE ${TEMPDIR}/$TITLE.log
	    d2v_error "${RED}exiting${NORMAL}"
	fi

	
	[ -z $AUDIOFORMATLINES ] && $AUDIOFORMATLINES="0"
	if [ $AUDIOFORMATLINES -eq 0 ] ; then
		AUDIOFORMAT="other"
	else
	AUDIOFORMAT="mp3"
	fi
	
	if [ $DEBUG -gt 1 ] ; then
		d2v_log_separator
		d2v_log_force "write output from transcode-audio.log"
		d2v_log "\$TRANSCODE_AUDIO='$TRANSCODE_AUDIO'"
		d2v_log_separator
		d2v_log_separator
		d2v_log_force "write output from transcode-audio2.log"
		d2v_log "\$TRANSCODE_AUDIO2='$TRANSCODE_AUDIO2'"
		d2v_log_separator
	fi

	d2v_log_force "\$AUDIOTRACK='$AUDIOTRACK'"
	d2v_log "\$AUDIOTYPE='$AUDIOTYPE'"
	d2v_log "\$AUDIOTYPELINES='$AUDIOTYPELINES'"
	d2v_log_force "\$AUDIOFORMAT='$AUDIOFORMAT'"
	d2v_log "\$AUDIOFORMATLINES='$AUDIOFORMATLINES'"

	case $AUDIOTYPE in
	    a??)
		TCEXTRACTOPTAUDIO="ac3"
		;;
	    *pcm|raw)
		TCEXTRACTOPTAUDIO="pcm"
		if [ ACTION_ENCODE != ${ENCODE_TOOLS[1]} ] ; then
		    ACTION_ENCODE=${ENCODE_TOOLS[1]}
		    d2v_log "pcm audio track found - \
			     forced the usage of '$ACTION_ENCODE'"
		fi
		;;
	    mpeg?)
		TCEXTRACTOPTAUDIO="mp2"
		;;
	    dts)
		TCEXTRACTOPTAUDIO="dts"
		;;
	    *)
		d2v_mesg "${MESG_06[$LNG]}"
		cat $TRANSCODE_AUDIO >> $LOGFILE
		cat $TRANSCODE_AUDIO2 >> $LOGFILE
		cp $LOGFILE ${TEMPDIR}/$TITLE.log
		d2v_error "${RED}exiting${NORMAL}"
		;;
	esac

	d2v_log_force "\$TCEXTRACTOPTAUDIO='$TCEXTRACTOPTAUDIO'"

	d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
    else
	d2v_log_force "\$AUDIOTRACK='$AUDIOTRACK'"
	d2v_log_force "\$AUDIOFORMAT='$AUDIOFORMAT'"
	d2v_log_force "\$TCEXTRACTOPTAUDIO='$TCEXTRACTOPTAUDIO'"
    fi
}


###########################################################################
# copy the main movie to disk
###########################################################################

copy () {
    d2v_log_separator
    d2v_log_force \
	"using '$ACTION_COPY' to copy the main movie to disk"

    if [ ! -f ${TEMPDIR}/001.vob -o $FORCE -eq 1 ] ; then

	# clean up
	[ -f ${TEMPDIR}/001.vob ] && rm -f ${TEMPDIR}/001.vob

	# read main movie off the DVD
	d2v_mesg "${MESG_03[$LNG]} TITEL: $TITLE NUM: $TITLENEM AUDIO: $TCEXTRACTOPTAUDIO"
	                    
	d2v_log "`echo && echo \$\> $TCCAT_BIN -t dvd -i $DVD_DEVICE \
	    -T $TITLENUM,-1 -L 2\> /dev/null \> ${TEMPDIR}/001.vob`"
	nice -n ${PRIO} $TCCAT_BIN -t dvd -i $DVD_DEVICE -T $TITLENUM,-1 \
	    -L 2> /dev/null > ${TEMPDIR}/001.vob

	local STATUS=$?
	if [ $STATUS -eq 1 ] ; then
	    d2v_mesg "${MESG_07[$LNG]}"
	    cp $LOGFILE ${TEMPDIR}/$TITLE.log
	    d2v_error "${MAGENTA}$TCCAT_BIN ${RED}failed - exiting${NORMAL}"
	fi

	# eject DVD
	d2v_mesg "${MESG_08[$LNG]}"
	$EJECT_BIN $DVD_DEVICE
	sleep $SLEEPTIME

	d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"

	if [ $AUDIOFORMAT = "mp3" ] ; then
	    d2v_log "`echo && echo \$\> mv ${TEMPDIR}/001.vob \
					   ${TEMPDIR}/001.mpeg`" && \
	    mv ${TEMPDIR}/001.vob ${TEMPDIR}/001.mpeg
	    d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
	fi
    fi
}


###########################################################################
# demultiplex the main movie in mpv and ac3
###########################################################################

demux () {
    d2v_log_separator
    d2v_log_force \
	"using '$ACTION_DEMUX' to demultiplex the main movie in mpv and ac3"

    if [ ! -f ${TEMPDIR}/001.vob ] ; then
	d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
	d2v_error "${MAGENTA}'${TEMPDIR}/001.vob' ${RED}not found${NORMAL}"
    fi

    if [ ! -f ${TEMPDIR}/001.mpv -o ! -f ${TEMPDIR}/001.ac3 -o $FORCE -eq 1 ] ; then

	# clean up
	[ -f ${TEMPDIR}/001.mpv ] && rm -f ${TEMPDIR}/001.mpv
	[ -f ${TEMPDIR}/001.ac3 ] && rm -f ${TEMPDIR}/001.ac3
	rm -f ${TEMPDIR}/video.fifo
	rm -f ${TEMPDIR}/audio.fifo

	local STATUS=1

	if [ "$AUDIOFORMAT" != "mp3" ] ; then
	    case $ACTION_DEMUX in
		${DEMUX_TOOLS[0]})

		    # demux using fifos and tcextract
		    d2v_mesg "${MESG_10[$LNG]}"
		    mkfifo ${TEMPDIR}/video.fifo
		    mkfifo ${TEMPDIR}/audio.fifo

		    d2v_log "`echo && echo \$\> $TCEXTRACT_BIN -i \
			${TEMPDIR}/video.fifo -t vob -x mpeg2 -a 0xe0 \
			\> ${TEMPDIR}/001.mpv \&`"

		    nice -n ${PRIO} $TCEXTRACT_BIN -i ${TEMPDIR}/video.fifo \
			-t vob -x mpeg2 -a 0xe0 \
			> ${TEMPDIR}/001.mpv &

		    d2v_log "`echo && echo \$\> $TCEXTRACT_BIN -i \
			${TEMPDIR}/audio.fifo -t vob -x ${TCEXTRACTOPTAUDIO} \
			-a $AUDIOTRACK \> ${TEMPDIR}/001.ac3 \&`"
		    nice -n ${PRIO} $TCEXTRACT_BIN -i ${TEMPDIR}/audio.fifo \
			-t vob -x ${TCEXTRACTOPTAUDIO} -a ${AUDIOTRACK} \
			> ${TEMPDIR}/001.ac3 &

		    sleep 5
		    d2v_log "`echo && echo \$\> cat ${TEMPDIR}/001.vob \| \
			tee ${TEMPDIR}/video.fifo ${TEMPDIR}/audio.fifo \
			\> /dev/null`"
		    nice -n ${PRIO} cat ${TEMPDIR}/001.vob | \
			tee ${TEMPDIR}/audio.fifo ${TEMPDIR}/video.fifo \
			> /dev/null

		    STATUS=$?
		;;
		${DEMUX_TOOLS[1]})

		    if [ $WITHOUT_X -eq 0 ] ; then
			# start virtual X server
			$XVFB_BIN -once :4 >/dev/null 2>&1 &
			export DISPLAY=localhost:4
		    fi

		    export LANG=de_DE@euro

		    # demux using projectX
		    d2v_log "`echo && echo \$\> $JAVA_BIN -jar $PROJECTX_JAR \
			-c $PROJECTX_INI -o ${TEMPDIR} \
			${TEMPDIR}/001.vob 2\>\&1 \>\> $LOGFILE`"
		    nice -n ${PRIO} $JAVA_BIN -jar $PROJECTX_JAR \
			-c $PROJECTX_INI -o ${TEMPDIR} \
			${TEMPDIR}/001.vob 2>&1 >> $LOGFILE

		    STATUS=$?

		    if [ $WITHOUT_X -eq 0 ] ; then
			# stop Virtual X server
			/usr/bin/killall Xvfb
		    fi
		    ;;
	    esac
	
	    if [ $STATUS -eq 1 ] ; then
		d2v_mesg "${MESG_09[$LNG]}"
		cp $LOGFILE ${TEMPDIR}/$TITLE.log
		d2v_error "${MAGENTA}$ACTION_DEMUX ${RED}failed - exiting${NORMAL}"
	    fi

	    d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
	else
	 d2v_log "demultiplexing not required - \
		main movie contains mp2 audio track"
	fi

    fi

    	[ $REMOVE -eq 1 ] && rm -f ${TEMPDIR}/001.vob

}


###########################################################################
# encode ac3 to mp2
###########################################################################

encode () {
    d2v_log_separator
    d2v_log_force \
	"using '$ACTION_ENCODE' to encode ac3 to mp2"

    if [ ! -f ${TEMPDIR}/001.ac3 ] ; then
	d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
	d2v_error "${MAGENTA}'${TEMPDIR}/001.ac3' ${RED}not found${NORMAL}"
    fi

    if [ ! -f ${TEMPDIR}/001.mp2 -o $FORCE -eq 1 ] ; then

	# clean up
	[ -f ${TEMPDIR}/001.mp2 ] && rm -f ${TEMPDIR}/001.mp2

	local STATUS=1

	if [ "$AUDIOFORMAT" != "mp3" ] ; then
	
		if [ "$TCEXTRACTOPTAUDIO" = "pcm" ] ; then
			d2v_log "pcm or raw audio track move to wav audio track"
			mv ${TEMPDIR}/001.ac3 ${TEMPDIR}/001.wav 
		fi
	
		if [ "$TCEXTRACTOPTAUDIO" != "pcm" ] ; then

	    # encode with a52dec ...
	    d2v_log "`echo && echo \$\> $A52DEC_BIN -o wavdolby \
		-g "$A52DEC_GAIN" ${TEMPDIR}/001.ac3 \
		2\>\&1 \> ${TEMPDIR}/001.wav \| grep -v \'last\' \
		\>\> $LOGFILE`"
	    nice -n ${PRIO} $A52DEC_BIN -o wavdolby \
		-g "$A52DEC_GAIN" ${TEMPDIR}/001.ac3 \
		2>&1 > ${TEMPDIR}/001.wav | grep -v 'last' \
		>> $LOGFILE

	    STATUS=$?
		    if [ $STATUS -eq 1 ] ; then
			d2v_mesg "${MESG_09[$LNG]}"
			cp $LOGFILE ${TEMPDIR}/$TITLE.log
			d2v_error "${MAGENTA}$A52DEC_BIN ${RED}failed - exiting${NORMAL}"
		    fi
		fi

	    d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"

	    case $ACTION_ENCODE in
		${ENCODE_TOOLS[0]})

		    # ... and mp2enc
		    d2v_log "`echo && echo \$\> cat ${TEMPDIR}/001.wav \| \
			$MP2ENC_BIN -r 48000 -o ${TEMPDIR}/001.mp2 \
			\> /dev/null 2\>\> $LOGFILE`"
		    nice -n ${PRIO} cat ${TEMPDIR}/001.wav | \
			$MP2ENC_BIN -r 48000 -o ${TEMPDIR}/001.mp2 \
			> /dev/null 2>> $LOGFILE
		    STATUS=$?
		    ;;
		${ENCODE_TOOLS[1]})

		    # ... and toolame
		    d2v_log "`echo && echo \$\> cat ${TEMPDIR}/001.wav \| \
			$TOOLAME_BIN -s 48 /dev/stdin ${TEMPDIR}/001.mp2 \
			\> /dev/null 2\>\> $LOGFILE`"
                    nice -n ${PRIO} cat ${TEMPDIR}/001.wav | \
			$TOOLAME_BIN -s 48 /dev/stdin ${TEMPDIR}/001.mp2 \
			> /dev/null 2>> $LOGFILE
		    STATUS=$?
		    ;;
	    esac

	    if [ $STATUS -eq 1 ] ; then
		d2v_mesg "${MESG_09[$LNG]}"
		cp $LOGFILE ${TEMPDIR}/$TITLE.log
		d2v_error "${MAGENTA}$ACTION_ENCODE ${RED}failed - exiting${NORMAL}"
	    fi

	    d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
	else
	    d2v_log "encoding not required - \
		 main movie contains mp2 audio track"
	fi
    fi
	[ $REMOVE -eq 1 ] && rm -f ${TEMPDIR}/001.wav

}


###########################################################################
# requant
###########################################################################

requant () {
    d2v_log_separator
    d2v_log_force \
	"using '$REQUANT_BIN' to multiplex the part to a VDR recording"

	if [ ! -f ${TEMPDIR}/001.mpv ] ; then
		d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
		d2v_error "${MAGENTA}'${TEMPDIR}/001.mpv' ${RED}not found${NORMAL}"
	fi

	MPVBIG=`ls -l ${TEMPDIR}/001.mpv | awk '{print $5}'`
	AC3BIG=`ls -l ${TEMPDIR}/001.ac3 | awk '{print $5}'`
	MP2BIG=`ls -l ${TEMPDIR}/001.mp2 | awk '{print $5}'`

	[ -z $AC3BIG ] && AC3BIG=0
	[ -z $MP2BIG ] && MP2BIG=0

	BIG=$(( $MPVBIG + $AC3BIG + $MP2BIG ))

	d2v_log_force "Dateiinfos \$MPVBIG='$MPVBIG' \$AC3BIG='$AC3BIG' \
	\$MP2BIG='$MP2BIG'  \$BIG='$BIG'"

	if [ $MP2BIG -eq 0 ] ; then
		FACTOR=`echo $MPVBIG $DVD_SIZE $AC3BIG|awk '{printf "%f\n",0.05+($1/($2-$3))}'| sed s/,/./g`
	else
		FACTOR=`echo $MPVBIG $DVD_SIZE $MP2BIG|awk '{printf "%f\n",0.05+($1/($2-$3))}' | sed s/,/./g`
	fi

	d2v_log_force "Faktor zum verkleinern \$FACTOR='$FACTOR'"

	if [ $BIG -gt $DVD_SIZE ] ; then

		d2v_mesg "${MESG_12[$LNG]}"

		# requant
		d2v_log "`echo && echo \$\> $REQUANT_BIN -f $FACTOR -i ${TEMPDIR}/001.mpv\
		-o ${TEMPDIR}/001.req 2\>\&1 \| grep -v \'%\' - \>\> $LOGFILE`"

		nice -n ${PRIO} $REQUANT_BIN -f $FACTOR -i ${TEMPDIR}/001.mpv \
		-o ${TEMPDIR}/001.req 2>&1 | grep -v '%' - >> $LOGFILE

		#local STATUS=$?
    		#if [ $STATUS -eq 1 ] ; then
		#	d2v_mesg "${MESG_09[$LNG]}"
		#	cp $LOGFILE ${TEMPDIR}/$TITLE.log
		#	d2v_error "${MAGENTA}$REQUANT_BIN ${RED}failed - exiting${NORMAL}"
		#fi

		mv ${TEMPDIR}/001.mpv ${TEMPDIR}/001.mpv.org
		mv ${TEMPDIR}/001.req ${TEMPDIR}/001.mpv

		d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
	else
		d2v_log "requant not required "
	fi
		[ $REMOVE -eq 1 ] && rm -f ${TEMPDIR}/001.mpv.org
}

###########################################################################
# multiplex the parts to a VDR recording
###########################################################################

mplex () {
    d2v_log_separator
    d2v_log_force \
	"using '$ACTION_MPLEX' to multiplex the part to a VDR recording"

    if [ ! -f ${TEMPDIR}/001.mpv ] ; then
	d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
	d2v_error "${MAGENTA}'${TEMPDIR}/001.mpv' ${RED}not found${NORMAL}"
    fi

    if [ ! -f ${TEMPDIR}/001.ac3 ] ; then
	d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
	d2v_error "${MAGENTA}'${TEMPDIR}/001.ac3' ${RED}not found${NORMAL}"
    fi

    if [ ! -f ${TEMPDIR}/001.mp2 ] ; then
	d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
	d2v_error "${MAGENTA}'${TEMPDIR}/001.mp2' ${RED}not found${NORMAL}"
    fi

    if [ ! -f ${TEMPDIR}/001.mpeg -o $FORCE -eq 1 ] ; then

	# clean up
	[ -f ${TEMPDIR}/001.mpeg ] && rm -f ${TEMPDIR}/001.mpeg

	if [ "$AUDIOFORMAT" != "mp3" ] ; then

	    local STATUS=1

	    d2v_mesg "${MESG_11[$LNG]}"

	    case $ACTION_MPLEX in
		${MPLEX_TOOLS[0]})
		    [ $AC3_TRACK = 1 ] && \
			INC_AC3_TRACK="-s ${TEMPDIR}/001.ac3"

		    # tcmplex a MPEG file
		    d2v_log "`echo && echo \$\> $TCMPLEX_BIN -m d \
			-i ${TEMPDIR}/001.mpv -p ${TEMPDIR}/001.mp2 \
			$INC_AC3_TRACK -o ${TEMPDIR}/001.mpeg \
			2\>\&1 \| grep -v \'%\' - \>\> $LOGFILE`"
		    nice -n ${PRIO} $TCMPLEX_BIN -m d \
			-i ${TEMPDIR}/001.mpv -p ${TEMPDIR}/001.mp2 \
			$INC_AC3_TRACK -o ${TEMPDIR}/001.mpeg \
			2>&1 | grep -v '%' - >> $LOGFILE
		    STATUS=$?
		    ;;
		${MPLEX_TOOLS[1]})
		    [ $AC3_TRACK = 1 ] && \
			INC_AC3_TRACK="-1 ${TEMPDIR}/001.ac3"

		    # tcmplex-panteltje a MPEG file
		    d2v_log "`echo && echo \$\> $TCMPLEX_PANTELTJE_BIN -m d \
			-i ${TEMPDIR}/001.mpv -0 ${TEMPDIR}/001.mp2 \
			$INC_AC3_TRACK -o ${TEMPDIR}/001.mpeg \
			2\>\&1 \| grep -v \'%\' - \>\> $LOGFILE`"
		    nice -n ${PRIO} $TCMPLEX_PANTELTJE_BIN -m d \
			-i ${TEMPDIR}/001.mpv -0 ${TEMPDIR}/001.mp2 \
			$INC_AC3_TRACK -o ${TEMPDIR}/001.mpeg \
			2>&1 | grep -v '%' - >> $LOGFILE
		    STATUS=$?
		    ;;
		${MPLEX_TOOLS[2]})
		    [ $AC3_TRACK = 1 ] && \
			INC_AC3_TRACK="${TEMPDIR}/001.ac3"

		    # mplex a MPEG file
		    d2v_log "`echo && echo \$\> $MPLEX_BIN -f 9 \
			-o ${TEMPDIR}/001.mpeg ${TEMPDIR}/001.mpv \
			${TEMPDIR}/001.mp2 $INC_AC3_TRACK \
			2\>\&1 \| grep -v \'%\' - \>\> $LOGFILE`"
		    nice -n ${PRIO} $MPLEX_BIN -f 9 \
			-o ${TEMPDIR}/001.mpeg ${TEMPDIR}/001.mpv \
			${TEMPDIR}/001.mp2 $INC_AC3_TRACK \
			2>&1 | grep -v '%' - >> $LOGFILE
		    STATUS=$?
		    ;;
	    esac

	    if [ $STATUS -eq 1 ] ; then
		d2v_mesg "${MESG_09[$LNG]}"
		cp $LOGFILE ${TEMPDIR}/$TITLE.log
		d2v_error "${MAGENTA}$ACTION_MPLEX ${RED}failed - exiting${NORMAL}"
	    fi

	    d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
	else
	    d2v_log "multiplexing not required - \
		main movie contains mp2 audio track"
	fi
    fi
    	[ $REMOVE -eq 1 ] && rm -f ${TEMPDIR}/001.mpv ${TEMPDIR}/001.mp2 ${TEMPDIR}/001.ac3

}


###########################################################################
# dvdauthor create a dvd structur
###########################################################################

dvdauthor () {
    d2v_log_separator
    d2v_log_force "using '$DVDAUTHOR_BIN' dvdauthor create a dvd structur"

    d2v_mesg "${MESG_17[$LNG]}"

    if [ ! -f ${TEMPDIR}/001.mpeg ] ; then
	d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"
	d2v_error "${MAGENTA}'${TEMPDIR}/001.mpeg' ${RED}not found${NORMAL}"
    fi

if [ ! -d ${TEMPDIR_ISO}/VIDEO_TS -o $FORCE -eq 1 ] ; then

	# clean up
	[ -f ${TEMPDIR_ISO}/VIDEO_TS ] && rm -rf ${TEMPDIR_ISO}/VIDEO_TS
	[ -f ${TEMPDIR_ISO}/AUDIO_TS ] && rm -rf ${TEMPDIR_ISO}/AUDIO_TS

cat << XMLEOF > ${TEMPDIR}/001.xml
<dvdauthor>
	<vmgm />
	<titleset>
		<titles>
			<pgc>
			<vob file="${TEMPDIR}/001.mpeg" />
		</pgc>
		</titles>
	</titleset>
</dvdauthor>
XMLEOF

	d2v_log "`echo && echo \$\> $DVDAUTHOR_BIN -o ${TEMPDIR_ISO} -x ${TEMPDIR}/001.xml`"
	nice -n ${PRIO} $DVDAUTHOR_BIN -o ${TEMPDIR_ISO} -x ${TEMPDIR}/001.xml

	local STATUS=$?
	if [ $STATUS -ne 0 ] ; then
		d2v_mesg "${MESG_09[$LNG]}"
		cp $LOGFILE ${TEMPDIR}/$TITLE.log
		d2v_error "${MAGENTA}$DVDAUTHORT_BIN ${RED}failed - exiting${NORMAL}"
	fi

	d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} ${TEMPDIR_ISO} \
		&& ls -l ${TEMPDIR} ${TEMPDIR_ISO}`"

fi
	[ $REMOVE -eq 1 ] && rm -f ${TEMPDIR}/001.mpeg
}

###########################################################################
# create an iso file
###########################################################################

iso () {

d2v_log_separator
d2v_log_force "using '$MKISOFS_BIN' to create a iso file"
d2v_mesg "${MESG_18[$LNG]}"
	
if [ ! -d ${TEMPDIR_ISO}/VIDEO_TS ] ; then
	d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} ${TEMPDIR_ISO} && ls -l ${TEMPDIR} ${TEMPDIR_ISO}`"
	d2v_error "${MAGENTA} '${TEMPDIR_ISO}/VIDEO_TS' ${RED}not found${NORMAL}"
fi

if [ ! -f ${TEMPDIR}/001.iso -o $FORCE -eq 1 ] ; then

	# clean up
	[ -f ${TEMPDIR}/001.iso ] && rm -f ${TEMPDIR}/001.iso
		
	d2v_log "`echo && echo \$\> $MKISOFS_BIN -dvd-video -o ${TEMPDIR}/001.iso ${TEMPDIR_ISO} \2\>\&1 \
	\>\> $LOGFILE`"
	nice -n ${PRIO} $MKISOFS_BIN -dvd-video -o ${TEMPDIR}/001.iso ${TEMPDIR_ISO} 2>&1 >> $LOGFILE

	local STATUS=$?
	if [ $STATUS -eq 1 ] ; then
		d2v_mesg "${MESG_09[$LNG]}"
		cp $LOGFILE ${TEMPDIR}/$TITLE.log
		d2v_error "${MAGENTA}$MKISOFS_BIN ${RED}failed - exiting${NORMAL}"
	fi

	d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} ${TEMPDIR_ISO} && ls -l ${TEMPDIR} ${TEMPDIR_ISO}`"
fi
	[ $REMOVE -eq 1 ] && rm -rf ${TEMPDIR_ISO}
}

###########################################################################
# burn recording 
###########################################################################

burn () {

if [ "$BURN" -eq 1 ] ; then

    d2v_log_separator
    d2v_log_force "using burn the DVD with '$GROWISOFS_BIN'"

    d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} && ls -l ${TEMPDIR}`"

	# insert DVD and do some checks
        
	local DVDCHECK="0"
        while [ "$DVDCHECK" -eq 0 ] ; do
        	#sleep $SLEEPTIME
        	d2v_mesg "${MESG_19[$LNG]}"
        	$EJECT_BIN $DVD_DEVICE
        	sleep $SLEEPTIME
        	$TCPROBE_BIN -i $DVD_DEVICE > /dev/null
        	$DVDSTATUS_BIN $DVD_DEVICE > ${TEMPDIR}/dvdstatus.log
       	        DVDTYPE=`cat ${TEMPDIR}/dvdstatus.log |grep 'Mounted Media' | awk '{print $4}'`
	        DVDSTATUS=`cat ${TEMPDIR}/dvdstatus.log | grep 'Disc status' | awk '{print $3}'`
	        if [ $DVDTYPE = "DVD-RW" ] ; then
		DVDTYPE="DVD+RW"
		fi
		if [ $DVDTYPE = "DVD-R" ] ; then
		DVDTYPE="DVD+R"
	        fi
		if [ $DVDTYPE = "DVD+R" -o $DVDTYPE = "DVD+RW" ] ; then
			DVDCHECK="1"
		else
	       		d2v_mesg "${MESG_02[$LNG]}"
			DVDCHECK="0"
		fi
		if [ $DVDSTATUS = "blank" ] ; then
			DVDCHECK="1"
	       	else 
	        	d2v_mesg "${MESG_02[$LNG]}"
			DVDCHECK="0"
	        fi
	done
                
	if [ "$RW_FORMAT" -eq 1 ] ; then
		if [ "$DVDTYPE" = "DVD+RW" ] ; then
			if [ "$DVDSTATUS" != "blank" ]; then
				d2v_mesg "${MESG_20[$LNG]}"
				sleep $SLEEPTIME
				$DVDFORMAT_BIN $DVD_DEVICE
			fi
		fi
	fi

	d2v_mesg "${MESG_21[$LNG]}"

	nice -n ${PRIO} $GROWISOFS_BIN $DVDFORMAT_OPT $DVD_DEVICE=${TEMPDIR}/001.iso

	local STATUS=$?
	if [ $STATUS -eq 1 ] ; then
		d2v_mesg "${MESG_23[$LNG]}"
		cp $LOGFILE ${TEMPDIR}/$TITLE.log
		d2v_error "${MAGENTA}$GROWISOFS_BIN ${RED}failed - exiting${NORMAL}"
	fi

	d2v_mesg "${MESG_22[$LNG]}"

	$EJECT_BIN $DVD_DEVICE

	sleep $SLEEPTIME

fi
	
}

###########################################################################
# move recording to video directory
###########################################################################

move () {
	if [ "$BURN" == "0" -o "$REMOVE_ISO" == "1" ] ; then 
		d2v_log_separator
		d2v_log_force "using 'mv' to move recording to iso directory"

		mkdir -p ${ISODIR} >> $LOGFILE || d2v_error "${RED}failed to create {MAGENTA}'${ISODIR}'${NORMAL}"
		d2v_log "'${ISODIR}' created"

		mv ${TEMPDIR}/001.iso ${ISODIR}/${TITLE}.iso

		d2v_log "`echo && echo \$\> ls -l ${TEMPDIR} ${ISODIR} && ls -l ${TEMPDIR} ${ISODIR}`"
	fi
	
}


###########################################################################
# do all the bits
###########################################################################

readvars

if [ $ACTION = "all" ] ; then
    gettitle
    test
    copy
    demux
    encode
    requant
    mplex
    dvdauthor
    iso
    burn
    move
elif [ $ACTION = "copy" ] ; then
	gettitle
	test
	eval $ACTION
fi

writevars


###########################################################################
# yeeha, we did it
###########################################################################

[ $ACTION = "all" -o $CLEAN = 1 ] && rm -rf $TEMPDIR && d2v_log "\$TEMPDIR '$TEMPDIR' deleted"

rm -f $LOCKFILE

d2v_log_separator
d2v_log_force END
d2v_log_separator
