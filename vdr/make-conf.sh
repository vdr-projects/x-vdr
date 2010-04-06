#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 29.07.2008

# defaults
source ./../x-vdr.conf
source ./../setup.conf
#VDRSCRIPTDIR="/usr/lib/vdr/scripts"
#VDRCONFDIR="."


# Function
function make_config() {
# create commands.conf
{
echo "# $VDRCONFDIR/commands.conf
# x-vdr `date '+%F %T'`
#

V D R                               : echo true
- Aktualisiere Liste der Aufnahmen  : sudo $VDRSCRIPTDIR/vdr2root video-update ; echo \"$VDRBINDIR/svdrpsend.pl HITK Red\"|at now
- Loeschen der EPG daten?           : echo \"$VDRBINDIR/svdrpsend.pl CLRE\"|at now
- VDR neustarten?                   : sudo $VDRSCRIPTDIR/vdr2root vdr-restart
- VDR beenden?                      : sudo $VDRSCRIPTDIR/vdr2root vdr-stop

S y s t e m                         : echo true
- Zeige /var/log/messages           : sudo $VDRSCRIPTDIR/vdr2root show-log
- Saeubere /var/log/messages        : sudo $VDRSCRIPTDIR/vdr2root clean-log
- Belegung der Laufwerke            : df -h|awk '/%/ { printf(\"%4.4s : %5.5s : %s\n\",\$5,\$4,\$6) }'
- Starte SSH?                       : sudo $VDRSCRIPTDIR/vdr2root ssh-start
- SSH ausschalten?                  : sudo $VDRSCRIPTDIR/vdr2root ssh-stop
- System neustarten?                : sudo $VDRSCRIPTDIR/vdr2root reboot
- System ausschalten?               : echo \"$VDRBINDIR/svdrpsend.pl HITK Power\"|at now
"

if [ "$burn" = "on" ]; then
echo "
B u r n - B C                       : echo true
- Blend  Only                       : echo \"$VDRBINDIR/burn-bc -f draw-storke -w default\"|at now
- Simple Cropping                   : echo \"$VDRBINDIR/burn-bc -f 'crop resize draw-storke unsharp' -w default\"|at now
- Zoom Center                       : echo \"$VDRBINDIR/burn-bc -f 'crop zoom-center resize draw-storke unsharp' -w default\"|at now
- Zoom Left                         : echo \"$VDRBINDIR/burn-bc -f 'crop zoom-left resize draw-storke unsharp' -w default\"|at now
- Zoom Right                        : echo \"$VDRBINDIR/burn-bc -f 'crop zoom-right resize draw-storke unsharp' -w default\"|at now
- Serial Foto                       : echo \"$VDRBINDIR/burn-bc -f 'crop zoom-center resize draw-storke serial-foto unsharp' -w default\"|at now
- Serial Movie                      : echo \"$VDRBINDIR/burn-bc -f 'crop zoom-center resize draw-storke serial-movie unsharp' -w default\"|at now
- Big Serial Movie                  : echo \"$VDRBINDIR/burn-bc -f 'crop zoom-center resize draw-bigsize serial-movie unsharp' -w default\"|at now
- 16x9 -> 4x3                       : echo \"$VDRBINDIR/burn-bc -f 'zoom-center-16x9 resize draw-storke unsharp' -w default\"|at now
"
fi

if [ -e "$DVDBURNER" ]; then
echo "
eject dvd                           : eject $DVDBURNER
"
fi

if [ "$vdrconvert" = "on" ]; then
echo "
V D R C o n v e r t - SVCD          : echo true
- Zu SVCD-Liste                     : ${PREFIX}/bin/ins.sh vdr2svcd
- Aktiviere SVCD-Liste              : ${PREFIX}/bin/convstart.sh vdr2svcd
- Entferne von SVCD-Liste?          : ${PREFIX}/bin/del.sh vdr2svcd
- Zeige SVCD-Liste                  : ${PREFIX}/bin/cap.sh vdr2svcd
V D R C o n v e r t - VCD           : echo true
- Zu VCD-Liste                      : ${PREFIX}/bin/ins.sh vdr2vcd
- Aktiviere VCD-Liste               : ${PREFIX}/bin/convstart.sh vdr2vcd
- Entferne von VCD-Liste?           : ${PREFIX}/bin/del.sh vdr2vcd
- Zeige VCD-Liste                   : ${PREFIX}/bin/cap.sh vdr2vcd
V D R C o n v e r t - DIVX          : echo true
- Zu DivX-Liste                     : ${PREFIX}/bin/ins.sh vdr2divx
- Aktiviere DivX                    : ${PREFIX}/bin/convstart.sh vdr2divx
- Entferne von DivX-Liste?          : ${PREFIX}/bin/del.sh vdr2divx
- Zeige DivX-Liste                  : ${PREFIX}/bin/cap.sh vdr2divx
V D R C o n v e r t - Quickmodus    : echo true
- Erstelle DivX sofort?             : ${PREFIX}/bin/convnow.sh vdr2divx
- Erstelle DVD sofort?              : ${PREFIX}/bin/convnow.sh vdr2dvd
- Erstelle Handy sofort?            : ${PREFIX}/bin/convnow.sh vdr2handy
- Erstelle PDA sofort?              : ${PREFIX}/bin/convnow.sh vdr2pda
- Erstelle SVCD sofort?             : ${PREFIX}/bin/convnow.sh vdr2svcd
- Erstelle VCD sofort?              : ${PREFIX}/bin/convnow.sh vdr2vcd
- Erstelle Mpeg ( sync )?           : ${PREFIX}/bin/convnow.sh vdr2mpg
- Erstelle Mp3?                     : ${PREFIX}/bin/convnow.sh vdr2mp3
- Erstelle ogg?                     : ${PREFIX}/bin/convnow.sh vdr2ogg
- Erstelle AC3?                     : ${PREFIX}/bin/convnow.sh vdr2ac3
"
fi

if [ "$vdrrip" = "on" ]; then
echo "
vdrrip starten                      : echo \"$VDRSCRIPTDIR/queuehandler.sh $VDRCONFDIR/plugins/queue.vdrrip /tmp\"|at now
"
fi

echo "
x-vdr setup                         : echo \"sudo /usr/lib/vdr/scripts/vdrsetup\"|at now
"
} > $VDRCONFDIR/commands.conf



# reccmds.conf
{
echo "# $VDRCONFDIR/reccmds.conf
# x-vdr `date '+%F %T'`
#
"

if [ "$pin" = "on" ]; then
echo "
FSK Schutz hinzufuegen              : $VDRSCRIPTDIR/fskprotect.sh protect
FSK Schutz entfernen                : $VDRSCRIPTDIR/fskprotect.sh unprotect
"
fi

if [ "$noad" = "on" ]; then
echo "
Werbung markieren                   : $VDRSCRIPTDIR/vdrnoad -start
M o r e  N o a d                    : echo true
- Run noad                          : $VDRSCRIPTDIR/vdrnoad -start
- Run noad, all recordings (batch)  : $VDRSCRIPTDIR/vdrnoad -batch
- View Cut list                     : $VDRSCRIPTDIR/vdrnoad -view
- In prozess                        : $VDRSCRIPTDIR/vdrnoad -count
- Stop noad (killpid)               : $VDRSCRIPTDIR/vdrnoad -killpid
- Stop noad (killall)?              : $VDRSCRIPTDIR/vdrnoad -killall
- Remove marks                      : $VDRSCRIPTDIR/vdrnoad -marks
- Remove pid                        : $VDRSCRIPTDIR/vdrnoad -pid
- Remove all marks                  : $VDRSCRIPTDIR/vdrnoad -marks.vdr
- Remove all pids                   : $VDRSCRIPTDIR/vdrnoad -noad.pid
"
fi

if [ "$vdrconvert" = "on" ]; then
echo "
V D R C o n v e r t                 : echo true
- Show VDRConvert Status            : ${PREFIX}/bin/status.sh
- Import Audio CD                   : echo 1 > /var/spool/vdrconvert/ripcda
- VDRConvert einschalten            : /etc/init.d/vdrconvert start >/dev/null 2>&1
- VDRConvert ausschalten            : /etc/init.d/vdrconvert stop >/dev/null 2>&1
"
fi
} > $VDRCONFDIR/reccmds.conf

# timercmds.conf
{
echo "# $VDRCONFDIR/timercmds.conf
# x-vdr `date '+%F %T'`
#
"

if [ "$epgsearch" = "on" ]; then
echo "
Suche nach Wiederholungen                   : $VDRSCRIPTDIR/timerrep.sh 0
Suche nach Wiederholungen mit Episodentitle : $VDRSCRIPTDIR/timerrep.sh 1
"
fi
} > $VDRCONFDIR/timercmds.conf

# setup.conf
{
echo "OSDHeight = 488
OSDLanguage = 1
OSDLeft = 62
OSDMessageTime = 1
OSDSkin = EnigmaNG
OSDTheme = default
OSDTop = 40
OSDWidth = 584
dvd.AudioLanguage = 1
dvd.Gain = 4
dvd.HideMainMenu = 0
dvd.MenuLanguage = 1
dvd.PlayerRCE = 2
dvd.ReadAHead = 0
dvd.ShowSubtitles = 0
dvd.SpuLanguage = 1
dvdselect.DVDOutputDir = $DVDISODIR
dvdselect.DVDReadScript = $VDRSCRIPTDIR/vdrreaddvd
dvdselect.DVDWriteScript = $VDRSCRIPTDIR/vdrwritedvd
dvdselect.ImageDir = $DVDISODIR
dvdselect.NameDevice = /dev/dvd
dvdselect.NameOrgDevice = /dev/hdc
dvdselect.ResetDVDLink = 1
femon.Skin = 0
femon.Theme = 4
mediamvp.dongle_version = 22146
osdpip.ColorDepth = 3
osdpip.CropBottom = 5
osdpip.CropLeft = 5
osdpip.CropRight = 5
osdpip.CropTop = 5
osdpip.FrameDrop = -1
osdpip.FrameMode = 2
osdpip.InfoPosition = 2
osdpip.InfoWidth = 400
osdpip.ShowInfo = 1
osdpip.Size = 2
osdpip.SwapFfmpeg = 1
osdpip.XPosition = 50
osdpip.YPosition = 50
setup.DirectMenu = 1
setup.EntryPrefix = :
setup.MenuSuffix = 
setup.ReturnValue = 1
ttxtsubs.MainMenuEntry = 3
"
} > $VDRCONFDIR/setup.conf

} # Function End

# Function Call
make_config


