#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 13.04.2009

# defaults
version="x-vdr-0.8.9"
name="Installations-Skript fuer einen VDR mit Debian als Basis"
args="$*"
config_mode="off"
direct_install="off"
exit_option="0"
DIALOG="dialog"
set_dirs="on"
set_vdrversion="on"
set_settings="on"
set_patchlevel="on"
XDIR=`pwd`

# superuser only
SU=$(which kanotix-su)
[ -n "$SU" ] || SU=$(which su-me)
if [ "`id -u`" != "0" ] && [ -n "$SU" ]; then
  exec $SU $0 $args -x || exit 1
  exit 0
fi

if [ "`id -u`" != "0" ]; then
  echo "$version"
  echo "Nur der Superuser \"root\" kann dieses Skript starten! "
  exit 1
fi

# shell testing
sh_version=$(readlink /bin/sh) #sh_version=$(/bin/sh --version)
if [ -z "$(echo "$sh_version" | grep "bash")" ] && [ -f /bin/bash ]; then
  echo "$version"
  echo " you are using the wrong shell"
  echo " but a compatible one (/bin/bash) was found on your system"
  echo " should x-vdr set the symlink /bin/sh to it [Y/n]? "
  read answer
  case "$answer" in
    ""|y*|Y*|j*|J*)
      mv -f /bin/sh /bin/sh.bak
      ln -sf /bin/bash /bin/sh
      exec $0 $args
      exit 0 ;;
    *)
      exit 1 ;;
  esac
elif [ -z "$(echo "$sh_version" | grep "bash")" ] && [ ! -f /bin/bash ]; then
  echo "$version"
  echo " you are using the wrong shell"
  echo " please install the bash on your system"
  echo " and set a symlink: ln -s /bin/bash /bin/sh"
  exit 1
fi

# dialog testing
if [ "$DIALOG" = "dialog" ]; then
  dialog_status=$(which dialog)
  if [ -z "$dialog_status" ]; then
    echo "$version"
    echo " dialog is not installed on your system but neccasary for x-vdr."
    echo " should x-vdr install it now [Y/n]? "
    read answer
    case "$answer" in
      ""|y*|Y*|j*|J*) apt-get update && apt-get install dialog ;;
      *) exit 1 ;;
    esac
    dialog_status=$(which dialog)
    [ -z "$dialog_status" ] && { echo "ERROR - dialog could not installed, exit"; exit 1; }
  fi
fi

# options
for i in $args; do
  case $1 in
    --dir|-d)
      shift 1
      [ -f "$1/x-vdr.conf" ] && XDIR="$1"
      ;;
    --config|-c)
      config_mode="on"
      ;;
    --install|-i)
      direct_install="on"
      ;;
    --xdialog|-x)
      DIALOG="Xdialog"
      ;;
    --no-xdialog|-n)
      DIALOG="dialog"
      ;;
    --help|-h)
      echo "$version - $name"
      echo "Moegliche Parameter sind:"
      echo "--dir|-d /path/to/x-vdr  -> Muss als erster Parameter uebergeben werden! "
      echo "                            Gefolgt von einer Pfadangabe zum x-vdr Verzeichnis"
      echo "--config|-c              -> VDR wird nicht beendet (funktioniert nicht zusammen mit --install)"
      echo "--install|-i             -> entfernt alten VDR und startet eine direkte Installation"
      echo "--xdialog|-x             -> Xdialog verwenden"
      echo "--no-xdialog|-n          -> dialog verwenden"
      echo "--help|-h                -> Zeigt was du siehst und beendet x-vdr"
      echo "--version|-v             -> Zeigt die Versionsnummer und beendet x-vdr"
      echo ""
      echo "Einzelne Parameter muessen durch eine Leerstelle getrennt werden."
      echo ""
      exit 0
      ;;
    --version|-v)
      echo "$version - $name"
      exit 0
      ;;
    *)
      [ "$1" != "" ] && echo "x-vdr: '$1' option ignored." 1>&2
      ;;
  esac
  shift 1
done

[ "$direct_install" = "on" ] && config_mode="off"

# auto-switch dialog/Xdialog
xdialog_status=$(which Xdialog)
if [ $DIALOG = "Xdialog" ] && [ -n "$DISPLAY" ] && [ -n "$xdialog_status" ]; then
  DIALOG="Xdialog" # --rc-file ./x-vdr.rc
  d_args="--left --wrap"
  d_size="0 0"
  # editor
  d_editor=`which kwrite`
  [ ! "$d_editor" ] && d_editor=`which gedit`
  if [ ! "$d_editor" ]; then
    rxvt -title " $version " -C -e $0 $args -n &
    exit 0
  fi
  d_editor=`basename $d_editor`
  # browser
  d_browser=`which konqueror`
  [ ! "$d_browser" ] && d_browser=`which nautilus`
  if [ ! "$d_browser" ]; then
    rxvt -title " $version " -C -e $0 $args -n &
    exit 0
  fi
  d_browser=`basename $d_browser`
else
  DIALOG="dialog"
  d_args=""
  d_size="19 70"
  d_editor="mcedit"
  d_browser="mc"
fi

### Functions ########################################################################################

# start info
function sd_start() {
  $DIALOG $d_args --title " $version - Information " --yesno \
"Dieses Skript steht ausschliesslich fuer die private, nicht kommerzielle Nutzung zur Verfuegung.
\nBeim ersten ausfuehren dieses Skripts ist eine Internet Verbindung erforderlich.
Das Skript laed etwa 50-100 MB an Daten, jenachdem welche Distribution verwendet wird.
\nDas Anpassen der sudoers mit visudo ist zwingend! Fuer weiter Informationen dazu, bitte einen Blick in die README werfen.
\n$version ist eine Testversion. Das Benutzen geschieht auf eigene Gefahr und es wird keine Haftung fuer Schaeden an Mensch oder Computer uebernommen.
\n\nSoll x-vdr jetzt gestartet werden?" $d_size
  [ $? != 0 ] && exit 1
}

# linux
function sd_linuxversion() {
  if [ -f /etc/kanotix-version ] && [ ! -f /etc/parsix-version ] && [ `grep -cw 'sidux' /etc/apt/sources.list` -eq 0 ]; then
    LINUXVERSION="kanotix"

  elif [ -f /etc/parsix-version ]; then
    LINUXVERSION="parsix"

  elif [ `grep -cw 'sidux' /etc/apt/sources.list` -gt 0 ]; then
    LINUXVERSION="sidux"

  elif [ `grep -cw 'ubuntu' /etc/apt/sources.list` -gt 0 ]; then
    LINUXVERSION="ubuntu"

  else # weder kanotix, parsix, sidux noch ubuntu gefunden
    option=`$DIALOG $d_args --title " $version - Linux Version " --radiolist \
    'Es wurde keine bestimmte Linux Version erkannt. \nWelcher Modus soll angeschaltet werden?' $d_size 7 \
    '1' 'Debian'      'on' \
    '2' 'Kanotix'    'off' \
    '3' 'Parsix'     'off' \
    '4' 'Sidux'      'off' \
    '5' 'Ubuntu'     'off' \
    '6' 'Ignorieren' 'off' 3>&1 1>&2 2>&3`
    if [ $? = 0 ]; then
      for i in $option; do
        case "$i" in
          1) LINUXVERSION="debian";  APT="on" ;;
          2) LINUXVERSION="kanotix"; APT="on" ;;
          3) LINUXVERSION="parsix";  APT="on" ;;
          4) LINUXVERSION="sidux";   APT="on" ;;
          5) LINUXVERSION="ubuntu";  APT="on" ;;
          6) LINUXVERSION="ignore" ;;
        esac
      done
    else
      return 1
    fi
  fi
  sd_write
  return 0
}

# vdr version
function sd_vdrversion() {
  # menu
  all_ext_patches=""
  if [ "$PATCHLEVEL" = "EXTENSIONS" ] || [ -z "$PATCHLEVEL" ]; then
    all_ext_patches=$(ls $XDIR/vdr/extensions | grep "^vdr-.*_extensions.diff$" | sed -e 's/.diff$/.diff\\n/g')
    [ -n "$all_ext_patches" ] && all_ext_patches="\nVorhandene Extensions Patches: \n${all_ext_patches}"
  fi

  TMP_VDRVERSION=`$DIALOG $d_args --title " $version - Konfiguration der VDR-Version " \
  --inputbox "Nur die VDR Version angeben, z.B.: 1.6.0 \n${all_ext_patches}\n" $d_size "$VDRVERSION" 3>&1 1>&2 2>&3`
  [ $? != 0 ] && return 1

  # test if vdrversion is valid
  TMP_VDRVERSION=$(echo "$TMP_VDRVERSION" | sed -e 's/ //' | grep "^1.[6-9].\+[0-9]$")
  if [ -z "$TMP_VDRVERSION" ]; then
    $DIALOG $d_args --title " $version - Eingabefehler " --msgbox "Die VDR Versions Nummer ist ungueltig!" $d_size
    return 1
  fi

  # activate patchlevel menu if vdr version has changed
  [ "$TMP_VDRVERSION" != "$VDRVERSION" ] && set_patchlevel="on"

  # vdr maintenance patches
  if [ $(( ${TMP_VDRVERSION:2:1} % 2 )) -eq 0 ]; then
    [ -n "$MTPATCHES" ] ||  MTPATCHES="1 2"
    TMP_MTPATCHES=`$DIALOG $d_args --title " $version - Konfiguration der MT-Patches " --inputbox \
    "Nur die Versions Nummern der MT-Patche angeben und mit Freistellen trennen\n z.B.: 1 2 3" $d_size "$MTPATCHES" 3>&1 1>&2 2>&3`
    [ $? != 0 ] && return 1
    MTPATCHES="$TMP_MTPATCHES"
  else
    MTPATCHES=""
  fi

  # dvb-driver for vdr-1.7.x
  if [ ${TMP_VDRVERSION:2:1} -gt 6 ] && [ "$INS_DVB" != "on" ]; then
    get_dvbapi
    if [ $DVB_API_VERSION -lt 5 ]; then
      api_wrapper_patch=$(ls -r $XDIR/vdr | grep -m1 "^vdr-${TMP_VDRVERSION}.*s2apiwrapper.*.diff$")
      [ -n "$api_wrapper_patch" ] && api_wrapper_info="\nAlternativ dazu wird der s2apiwrapper Patch angewendet."
      $DIALOG $d_args --title " $version - HDTV " --yesno \
      "Fuer diese VDR Version sind spezielle Treiber notwendig. Sollen diese im Anschluss erstellt werden? $api_wrapper_info" $d_size
      [ $? = 0 ] && INS_DVB="on"
    fi
  fi

  # extensions-patch
  if [ "$PATCHLEVEL" = "EXTENSIONS" ] || [ -z "$PATCHLEVEL" ]; then
    extensions_patch=$(ls -r $XDIR/vdr/extensions | grep -m1 "^vdr-${TMP_VDRVERSION}_extensions.diff$")
    [ -n "$extensions_patch" ] || extensions_patch=$(ls -r $XDIR/vdr/extensions | grep -m1 "^vdr-${TMP_VDRVERSION}.*_extensions.diff$")
    if [ -z "$extensions_patch" ]; then
      extensions_patch=$(ls -r $XDIR/vdr/extensions | grep -m1 "^vdr-.*_extensions.diff$")
      [ -n "$extensions_patch" ] && extensions_patch="\nMoechtest du es mit diesem versuchen: \n${extensions_patch}"
      $DIALOG $d_args --title " $version - Extensions " --yesno \
      "Es wurde kein passender Extensions Patch gefunden! \n $extensions_patch" $d_size
      [ $? != 0 ] && PATCHLEVEL="PATCHES"
    fi
  fi

  # write to setup.conf
  VDRVERSION="$TMP_VDRVERSION"
  sd_write && return 0
}

# settings (update)
function sd_update() {
  if [ -f /usr/bin/vdr-kbd ] && [ "$INSTALL_MODE" != "ignore" ]; then # kanotix-vdr gefunden
    option=`$DIALOG $d_args --title " $version - Update - Einstellungen " --radiolist \
    'Kanotix-VDR wurde auf dem System gefunden.\nWas moechtest du tun?' $d_size 3 \
    '1' 'Kanotix-VDR deinstallieren' 'on' \
    '2' 'Ignorieren' 'off' 3>&1 1>&2 2>&3`
    if [ $? = 0 ]; then
      for i in $option; do
        case "$i" in
          1) INSTALL_MODE="force"; APT="on"; VDRUPDATE="off"; sd_write ; return 0 ;;
          2) INSTALL_MODE="ignore" ;;
        esac
      done
    else
      return 1
    fi
  fi
  if [ -f $VDRPRG -o -f $SOURCEDIR/VDR/config.h ]; then # vdr oder vdr-sourcen gefunden
    if [ -f $VDRPRG ] && [ -f $SOURCEDIR/VDR/config.h ]; then # vdr-sourcen gefunden
      version_vdr=`egrep '.*VDRVERSION.*"' $SOURCEDIR/VDR/config.h | sed -e 's/.* "//' | sed -e 's/[";]//g' | tr -d '\015' | tr -d '\012'`
    elif [ -f $VDRPRG ] && [ ! -f $SOURCEDIR/VDR/config.h ]; then
      $DIALOG $d_args --title " $version - Fehler " --yesno \
      "Ein Fehler ist aufgetreten. \nVDR ist schon installiert ($VDRPRG). \nEs wurden aber keine Sourcen gefunden! \nSoll die Installation abgebrochen werden?" $d_size
      [ $? = 0 ] && return 1
    elif [ ! -f $VDRPRG ] && [ -f $SOURCEDIR/VDR/config.h ]; then
      $DIALOG $d_args --title " $version - Fehler " --yesno \
      "Ein Fehler ist aufgetreten. \nEs wurden nur die Sourcen aber keine VDR gefunden! \nSoll die Installation abgebrochen werden?" $d_size
      [ $? = 0 ] && return 1
    fi
    option=`$DIALOG $d_args --title " $version - Update " --radiolist \
    "VDR-$version_vdr ist schon installiert:\n$VDRPRG" $d_size 4 \
    '1' 'VDR wird entfernt und neu installiert' 'on' \
    '2' 'Update des VDR und der Plugins' 'off' \
    '3' 'Update des VDR versuchen' 'off' 3>&1 1>&2 2>&3`
    if [ $? = 0 ]; then
      case $option in
        1) options=`$DIALOG $d_args --separate-output --title " $version - Update - Einstellungen " --checklist \
          'Aktiviere die Menus, die du benoetigst' $d_size 6 \
           '1' 'Einstellungen aendern'  'off' \
           '2' 'Utilities installieren' 'off' \
           '3' 'System aktualisieren mit apt-get' 'off' \
           '4' 'Verzeichnisse aendern' 'off' \
           '5' 'Patchlevel anpassen' 'off' 3>&1 1>&2 2>&3`
           if [ $? = 0 ]; then
             # new settings
             VDRUPDATE="off"; APT="off"; INS_UTILITIES="off"; INS_PLUGINS="on"; set_settings="off"; set_dirs="off"; set_patchlevel="off"
             for i in $options; do
               case "$i" in
                 1) set_settings="on" ;;
                 2) INS_UTILITIES="on" ;;
                 3) APT="on" ;;
                 4) set_dirs="on" ;;
                 5) set_patchlevel="on" ;;
               esac
             done
           else
             return 1
           fi
         ;;
        2) VDRUPDATE="on";  APT="off"; INS_UTILITIES="off"; INS_PLUGINS="on";  set_settings="off"; set_dirs="off"; set_patchlevel="off" ;;
        3) VDRUPDATE="on";  APT="off"; INS_UTILITIES="off"; INS_PLUGINS="off"; set_settings="off"; set_dirs="off"; set_patchlevel="off" ;;
        *) VDRUPDATE="off"; APT="on";  INS_UTILITIES="on";  INS_PLUGINS="on";  set_settings="on";  set_dirs="on";  set_patchlevel="on"; return 1 ;;
      esac
      # write to setup.conf
      sd_write && return 0
#      sed -i -e s/'VDRUPDATE=off'/'VDRUPDATE=on'/g $XDIR/setup.conf
    else
      return 1
    fi
  else
    VDRUPDATE="off"
    # write to setup.conf
    sd_write && return 0
  fi
}

# vdr setup
function sd_dirs() {
  $DIALOG $d_args --title " $version - Konfiguration der Laufwerke und Verzeichnisse " --msgbox \
"In den folgenden Dialogen kannst du die notwendigen Verzeichnisse anpassen.
Nicht existierende Verzeichnisse werden dabei automatisch erstellt.
\n
\nBitte keine Verzeichnisse innerhalb des Video-Verzeichnisses anlegen! " $d_size

  TMP_VIDEODIR=`$DIALOG $d_args --title " $version - Konfiguration der Laufwerke und Verzeichnisse " \
  --inputbox "Das Video-Verzeichnis" $d_size "$VIDEODIR" 3>&1 1>&2 2>&3`
  [ $? != 0 ] && return 1
  VIDEODIR="$TMP_VIDEODIR"
  TMP_MUSICDIR=`$DIALOG $d_args --title " $version - Konfiguration der Laufwerke und Verzeichnisse " \
  --inputbox "Das Musik-Verzeichnis" $d_size "$MUSICDIR" 3>&1 1>&2 2>&3`
  [ $? != 0 ] && return 1
  MUSICDIR="$TMP_MUSICDIR"
  TMP_DIVXDIR=`$DIALOG $d_args --title " $version - Konfiguration der Laufwerke und Verzeichnisse " \
  --inputbox "Das MPlayer-Verzeichnis" $d_size "$DIVXDIR" 3>&1 1>&2 2>&3`
  [ $? != 0 ] && return 1
  DIVXDIR="$TMP_DIVXDIR"
  TMP_PICTUREDIR=`$DIALOG $d_args --title " $version - Konfiguration der Laufwerke und Verzeichnisse " \
  --inputbox "Das Bilder-Verzeichnis" $d_size "$PICTUREDIR" 3>&1 1>&2 2>&3`
  [ $? != 0 ] && return 1
  PICTUREDIR="$TMP_PICTUREDIR"
  TMP_DVDISODIR=`$DIALOG $d_args --title " $version - Konfiguration der Laufwerke und Verzeichnisse " \
    --inputbox "Das DVD-Image-Verzeichnis" $d_size "$DVDISODIR" 3>&1 1>&2 2>&3`
  [ $? != 0 ] && return 1
  DVDISODIR="$TMP_DVDISODIR"

  all_dvd=$(ls -r /dev/* | grep "^/dev/[c,d][d,v][r,d]")
  TMP_DVDBURNER=`$DIALOG $d_args --title " $version - Konfiguration der Laufwerke und Verzeichnisse " \
  --inputbox "Hier kannst du DVD-Brenner oder CD-Laufwerk eintragen.\nVerfuegbare Laufwerke: $all_dvd" $d_size "$DVDBURNER" 3>&1 1>&2 2>&3`
  [ $? != 0 ] && return 1
  DVDBURNER="$TMP_DVDBURNER"
  # write to setup.conf
  sd_write && return 0
}

# settings
function sd_settings() {
  RUNLEVEL_STR="id:5:initdefault:"
  RUNLEVEL=5
  if [ -f /etc/inittab ]; then
    RL="$(sed -n -e "/^id:[0-9]*:initdefault:/{s/^id://;s/:.*//;p}" /etc/inittab || true)"
    if [ -n "$RL" ]; then
      RUNLEVEL_STR="$(cat /etc/inittab | grep -m1 ^id:)"
      RUNLEVEL=$RL
    fi
  else
    log "creating /etc/inittab"
    echo "# The default runlevel." > /etc/inittab
    echo "$RUNLEVEL_STR"          >> /etc/inittab
    echo ""                       >> /etc/inittab
  fi

  if [ $RUNLEVEL -eq 5 ]; then
    DESKTOP="on"
  else
    DESKTOP="off"
  fi

  XWRAPPER_STR="$(cat /etc/X11/Xwrapper.config | grep -m1 ^allowed_users)"
  XWRAPPER=$(echo $XWRAPPER_STR | cut -f2 -d"=")

  # dialog (settings)
  options=`$DIALOG $d_args --separate-output --title " $version - Einstellungen " --checklist \
  'Aktiviere deine Optionen' $d_size 7 \
  '1' 'VDR mit Lirc unterstuetzung erstellen'        "$USELIRC" \
  '2' 'VDR mit VFAT unterstuetzung erstellen'        "$USEVFAT" \
  '3' 'VDR und die Plugins mit "strip" verkleineren' "$STRIP" \
  '4' 'VDR automatisch mit dem System starten'       "$AUTOSTART" \
  '5' 'Xserver und Player mit dem VDR starten'       "$XPLAYER" \
  '6' 'Desktop-Manager mit dem System starten'       "$DESKTOP" 3>&1 1>&2 2>&3`
  if [ $? = 0 ]; then
    # new settings
    USELIRC="off"
    USEVFAT="off"
    STRIP="off"
    AUTOSTART="off"
    XPLAYER="off"
    DESKTOP="off"

    for i in $options; do
      case "$i" in
        1) USELIRC="on" ;;
        2) USEVFAT="on" ;;
        3) STRIP="on" ;;
        4) AUTOSTART="on";;
        5) XPLAYER="on" ;;
        6) DESKTOP="on" ;;
      esac
    done

    [ "$XPLAYER" = "on" ] && DESKTOP="off"

    # write to /etc/default/vdr
    if [ -f /etc/default/vdr ]; then
      as=$(grep "^AUTOSTART=" /etc/default/vdr | tail -n1)
      as_val=$(echo $as | cut -f 2 -d '=')
      as_val=$(eval echo $as_val)

      if [ "$as_val" != "$AUTOSTART" ]; then
        sed -i /etc/default/vdr -e "s/$as/AUTOSTART=\"$AUTOSTART\"/g"
      fi

      vp=$(grep "^XPLAYER=" /etc/default/vdr | tail -n1)
      vp_val=$(echo $vp | cut -f 2 -d '=')
      vp_val=$(eval echo $vp_val)

      if [ "$vp_val" != "$XPLAYER" ]; then
        sed -i /etc/default/vdr -e "s/$vp/XPLAYER=\"$XPLAYER\"/g"
      fi
    fi

    # runlevel
    if [ $RUNLEVEL -eq 5 -a "$DESKTOP" = "off" ]; then
      sed -i /etc/inittab -e "s/$RUNLEVEL_STR/id:3:initdefault:/"
    elif [ $RUNLEVEL -ne 5 -a "$DESKTOP" = "on" ]; then
      sed -i /etc/inittab -e "s/$RUNLEVEL_STR/id:5:initdefault:/"
    fi

    if [ "$DESKTOP" != "on" -a "$XWRAPPER" != "anybody" ]; then
      log "Setting 'allowed_users' to 'anybody' in /etc/X11/Xwrapper.config"
      sed -i /etc/X11/Xwrapper.config -e "s/$XWRAPPER_STR/allowed_users=anybody/g"
    fi

    # write to setup.conf
    sd_write && return 0
  else
    return 1
  fi
}

# verify input (utilitie-settings)
function verify_utilities() {
  em8300=`verify_input "$em8300"`
  ffmpeg=`verify_input "$ffmpeg"`
  graphlcd_base=`verify_input "$graphlcd_base"`
  LCDproc=`verify_input "$LCDproc"`
  lirc=`verify_input "$lirc"`
  mplayer=`verify_input "$mplayer"`
  noad=`verify_input "$noad"`
  projectx=`verify_input "$projectx"`
  vdradmin=`verify_input "$vdradmin"`
  vdrfonts=`verify_input "$vdrfonts"`
  vidix=`verify_input "$vidix"`
  xine_lib=`verify_input "$xine_lib"`
  case "$xine_lib_vers" in
    2) xine_lib_vers=2 ;;
    3) xine_lib_vers=3 ;;
    *) xine_lib_vers=1 ;;
  esac
}

# setup utilities
function sd_utilities() {
  # dialog (utilitie auswahl)
  options=`$DIALOG $d_args --separate-output --title " $version - Utilities " --checklist \
  'Aktiviere die Utilities, die installiert werden sollen. \nDeaktivierte Utilities, die schon installiert sind, werden entfernt!' $d_size 12 \
  '1'  'em8300(dxr3)'       "$em8300" \
  '2'  'ffmpeg'             "$ffmpeg" \
  '3'  'graphlcd-base'      "$graphlcd_base" \
  '4'  'LCDproc'            "$LCDproc" \
  '5'  'lirc'               "$lirc" \
  '6'  'mplayer'            "$mplayer" \
  '7'  'noad'               "$noad" \
  '8'  'projectx'           "$projectx" \
  '9'  'vdradmin'           "$vdradmin" \
  '10' 'vdrfonts'           "$vdrfonts" \
  '11' 'vidix'              "$vidix" \
  '12' 'xine-lib + xine-ui' "$xine_lib" 3>&1 1>&2 2>&3`
  if [ $? = 0 ]; then
    # new settings (utilities)
    em8300="off"; dxr3="off"
    ffmpeg="off"
    graphlcd_base="off"; graphlcd="off"
    LCDproc="off"; lcdproc="off"
    lirc="off"
    mplayer="off"
    noad="off"
    projectx="off"
    vdradmin="off"
    vdrfonts="off"
    vidix="off"
    xine_lib="off"; xine="off"; xineliboutput="off"

    for i in $options; do
      case "$i" in
        1)  em8300="on"; dxr3="on" ;;
        2)  ffmpeg="on" ;;
        3)  graphlcd_base="on"; graphlcd="on" ;;
        4)  LCDproc="on"; lcdproc="on" ;;
        5)  lirc="on" ;;
        6)  mplayer="on" ;;
        7)  noad="on" ;;
        8)  projectx="on" ;;
        9)  vdradmin="on" ;;
        10) vdrfonts="on" ;;
        11) vidix="on" ;;
        12) xine_lib="on"; xine="on"; xineliboutput="on" ;;
      esac
    done

    # setup lirc
    if [ "$lirc" = "on" ]; then
      case $lirc_port in
        2) lirc_port1="off"; lirc_port2="on" ;;
        *) lirc_port1="on"; lirc_port2="off" ;;
      esac
      option=`$DIALOG $d_args --title " $version - Utilities - Lirc " --radiolist \
      'An welchem Serial-Port ist der Lirc-Empfaenger angeschlossen?' $d_size 3 \
      '1' 'PORT=0x3f8 IRQ=4' $lirc_port1 \
      '2' 'PORT=0x2f8 IRQ=3' $lirc_port2 3>&1 1>&2 2>&3`
      if [ $? = 0 ]; then
        case $option in
          2) lirc_port=2 ;;
          *) lirc_port=1 ;;
        esac
      else
        return 1
      fi
    fi

    # setup xine-lib version
    if [ "$xine_lib" = "on" ]; then
      # ffmpeg-svn needs xine-lib-hg
      [ "$ffmpeg" = "on" ] && [ "$xine_lib_vers" != "2" -a "$xine_lib_vers" != "3" ] && xine_lib_vers=2
      # on / off
      case $xine_lib_vers in
        2) xine_lib_vers1="off"; xine_lib_vers2="on";  xine_lib_vers3="off";;
        3) xine_lib_vers1="off"; xine_lib_vers2="off"; xine_lib_vers3="on";;
        *) xine_lib_vers1="on";  xine_lib_vers2="off"; xine_lib_vers3="off"; xine_lib_vers=1;;
      esac
      option=`$DIALOG $d_args --title " $version - Utilities - Xine " --radiolist \
      'Welche Xine Version soll installiert werden?' $d_size 3 \
      '1' 'xine'          $xine_lib_vers1 \
      '2' 'xine-hg'       $xine_lib_vers2 \
      '3' 'xine-hg-vdpau' $xine_lib_vers3 3>&1 1>&2 2>&3`
      if [ $? = 0 ]; then
        case $option in
          2) xine_lib_vers=2 ;;
          3) xine_lib_vers=3 ;;
          *) xine_lib_vers=1 ;;
        esac
      else
        return 1
      fi
    fi

    # write to setup.conf
    sd_write && return 0
  else
    return 1
  fi
}

# setup plugins
function sd_plugins() {
  xPlugins -l
  # dialog (plugin auswahl)
  echo "options=\`$DIALOG $d_args --separate-output --title \" $version - Plugins \" --checklist \
  'Aktiviere die Plugins, die installiert werden sollen \nBei den Plugins, die mit *! gekennzeichnet sind, muss der VDR neu erstellt werden.' $d_size 12 \
  $plugin_list  3>&1 1>&2 2>&3\`" > /tmp/x-vdr.tmp
  . /tmp/x-vdr.tmp
  if [ $? = 0 ]; then
    # alle plugins auf "off" stellen
    xPlugins -o
    # aktivierte plugins wieder auf "on" stellen
    for plugin in $options; do
      eval ${plugin}=on
      # Abhaengigkeiten erfuellen
      [ "$plugin" = "remoteosd" -o "$plugin" = "remotetimers" ] && svdrpservice=on
    done

    # die neuen einstellungen in die setup.conf schreiben
    rm /tmp/x-vdr.tmp
    sd_write && return 0
  else
    rm /tmp/x-vdr.tmp
    return 1
  fi
}

# skins
function sd_skins() {
  echo "not yet"
}

# einstellungen in die setup.conf schreiben
function sd_write() {
  [ "$menuorg" = "on" ] && setup="off" && submenu="off"
  [ "$setup" = "on" ] && submenu="off"
  {
  echo "# $version `date '+%F %T'`"
  echo "# $setup_file"
  # settings
  echo ""
  echo "# Settings"
  echo "LINUXVERSION=\"$LINUXVERSION\""
  echo "VDRVERSION=\"$VDRVERSION\""
  echo "MTPATCHES=\"$MTPATCHES\""
  echo "INSTALL_MODE=\"$INSTALL_MODE\""
  echo "VDRUPDATE=\"$VDRUPDATE\""
  echo "USELIRC=\"$USELIRC\""
  echo "USEVFAT=\"$USEVFAT\""
  echo "STRIP=\"$STRIP\""
  # vdr
  echo ""
  echo "# VDR"
  echo "VDRPRG=\"$VDRPRG\""
  echo "AUTOSTART=\"$AUTOSTART\""
  echo "XPLAYER=\"$XPLAYER\""
  echo "KEYB_TTY=\"$KEYB_TTY\""
  echo "WATCHDOG=$WATCHDOG"
  echo "XV_DISPLAY=$XV_DISPLAY"
  # dirs
  echo ""
  echo "# Verzeichnisse"
#  echo "SOURCEDIR=\"$SOURCEDIR\""
  echo "MEDIADIR=\"$MEDIADIR\""
  echo "VIDEODIR=\"$VIDEODIR\""
  echo "MUSICDIR=\"$MUSICDIR\""
  echo "DIVXDIR=\"$DIVXDIR\""
  echo "PICTUREDIR=\"$PICTUREDIR\""
  echo "DVDISODIR=\"$DVDISODIR\""
  echo "DVDBURNER=\"$DVDBURNER\""
  echo ""
  echo "VDRBINDIR=\"$VDRBINDIR\""
  echo "VDRCONFDIR=\"$VDRCONFDIR\""
  echo "VDRLIBDIR=\"$VDRLIBDIR\""
  echo "VDRMANDIR=\"$VDRMANDIR\""
  echo "VDRSCRIPTDIR=\"$VDRSCRIPTDIR\""
  echo "VDRVARDIR=\"$VDRVARDIR\""
  # utilities
  echo ""
  echo "# Utilities"
  echo "em8300=\"$em8300\""
  echo "ffmpeg=\"$ffmpeg\""
  echo "graphlcd_base=\"$graphlcd_base\""
  echo "LCDproc=\"$LCDproc\""
  echo "lirc=\"$lirc\""
  echo "lirc_port=\"$lirc_port\""
  echo "mplayer=\"$mplayer\""
  echo "noad=\"$noad\""
  echo "projectx=\"$projectx\""
  echo "vdradmin=\"$vdradmin\""
  echo "vdrfonts=\"$vdrfonts\""
  echo "vidix=\"$vidix\""
  echo "xine_lib=\"$xine_lib\""
  echo "xine_lib_vers=\"$xine_lib_vers\""
  # plugins
  echo ""
  echo "# Plugins"
  xPlugins -s
  echo ""
#### no menu
#  # skins fuer text2skin
#  echo "# Skins for text2skin"
#  echo "SKINS=\\"
#  echo "\"$SKINS\""
#  echo ""
  } > $setup_file
}

# vdr patchlevel
function sd_patchlevel() {
  PATCHLEVEL="EXTENSIONS"
  [ -f $XDIR/vdr/patchlevel.conf ] && source $XDIR/vdr/patchlevel.conf

  verify_patchlevel

  # menu
  if [ "$PATCHLEVEL" = "EXTENSIONS" ]; then
    options=`$DIALOG $d_args --separate-output --title " $version - Extensions " --checklist \
    'Welche Patches sollen angewendet werden? \nPlugin-Patches werden automatisch ausgefuehrt, wenn das entsprechende Plugin aktiviert ist.' $d_size 12 \
    'ANALOGTV'          'Analogtv-, Pvrinput- und Pvrusb2-Plugin'      "$ANALOGTV" \
    'ATSC'              'Unterstuetzung fuer ATSC'                     "$ATSC" \
    'CHANNELSCAN'       'Reelchannelscan-Plugin'                       "$CHANNELSCAN" \
    'CMDRECCMDI18N'     'Laed uebersetzte Befehle wenn vorhanden'      "$CMDRECCMDI18N" \
    'CMDSUBMENU'        'Untermenus bei den Befehlen'                  "$CMDSUBMENU" \
    'CUTTERLIMIT'       'Bandbreite beim Schneiden limitieren'         "$CUTTERLIMIT" \
    'CUTTERQUEUE'       'Warteschleife beim Schneiden'                 "$CUTTERQUEUE" \
    'CUTTIME'           'Anpassen der Startzeit beim Schneiden'        "$CUTTIME" \
    'DDEPGENTRY'        'Entfernt doppelte EPG Eintraege'              "$DDEPGENTRY" \
    'DELTIMESHIFTREC'   'Kann zeit versetzte Aufnahmen loeschen'       "$DELTIMESHIFTREC" \
    'DOLBYINREC'        'Dolby Digital in Aufnahmen'                   "$DOLBYINREC" \
    'DVBPLAYER'         'Editieren aelterer Aufnahmen'                 "$DVBPLAYER" \
    'DVBSETUP'          'AC3-Transfer, Kanal sperren, etc'             "$DVBSETUP" \
    'DVDARCHIVE'        'DMH DVD-Archive'                              "$DVDARCHIVE" \
    'DVDCHAPJUMP'       'Kapitel weise springen mit Archive-Disks'     "$DVDCHAPJUMP" \
    'DVLFRIENDLYFNAMES' 'Filter fuer Dateinamen bei Aufnahmen'         "$DVLFRIENDLYFNAMES" \
    'DVLRECSCRIPTADDON' 'Erweiterung fuer das Aufnahme-Skript'         "$DVLRECSCRIPTADDON" \
    'DVLVIDPREFER'      'Videozeichnispolitik fuer Aufnahmen'          "$DVLVIDPREFER" \
    'EM84XX'            'EM84xx-Plugin'                                "$EM84XX" \
    'GRAPHTFT'          'Graphtft-Plugin'                              "$GRAPHTFT" \
    'HARDLINKCUTTER'    'Video-Schnitt beschleunigen'                  "$HARDLINKCUTTER" \
    'JUMPPLAY'          'Automatisch springen in Aufnahmen'            "$JUMPPLAY" \
    'LIEMIEXT'          'Liemikuutio mit Erweiterungen'                "$LIEMIEXT" \
    'LIRCSETTINGS'      'Lirc-Einstellungen im OSD'                    "$LIRCSETTINGS" \
    'LIVEBUFFER'        'Zeit versetztes Fernsehen'                    "$LIVEBUFFER" \
    'LNBSHARE'          'Ein LNB und zwei Sat-Karten'                  "$LNBSHARE" \
    'MAINMENUHOOKS'     'VDR-Menus durch Plugins ersetzen'             "$MAINMENUHOOKS" \
    'MENUORG'           'Menuorg-Plugin'                               "$MENUORG" \
    'NOEPG'             'NoEpgMenu-Plugin'                             "$NOEPG" \
    'OSDMAXITEMS'       'Text2Skin-Plugin'                             "$OSDMAXITEMS" \
    'PARENTALRATING'    'Parental Rating Content'                      "$PARENTALRATING" \
    'PINPLUGIN'         'Pin-Plugin'                                   "$PINPLUGIN" \
    'PLUGINAPI'         'Autopatch Plugin-Makefiles (API)'             "$PLUGINAPI" \
    'PLUGINMISSING'     'VDR startet trotz fehlender Plugins'          "$PLUGINMISSING" \
    'PLUGINPARAM'       'IpTv-Plugin und andere'                       "$PLUGINPARAM" \
    'ROTOR'             'Rotor-Plugin'                                 "$ROTOR" \
    'SETTIME'           'Systemzeit per Skript stellen'                "$SETTIME" \
    'SETUP'             'Setup-Plugin und Menu-Erweiterungen'          "$SETUP" \
    'SOFTOSD'           'Sanftes Ein- und Ausblenden des OSD (FF)'     "$SOFTOSD" \
    'SOURCECAPS'        'Verschiedene Satelliten'                      "$SOURCECAPS" \
    'SORTRECORDS'       'Aufnahmen sortieren'                          "$SORTRECORDS" \
    'STREAMDEVEXT'      'Erweiterung fuer das Streamen zu XBMC'        "$STREAMDEVEXT" \
    'SYNCEARLY'         'Schnellere Umschaltzeit im Transfer Mode'     "$SYNCEARLY" \
    'TIMERCMD'          'Befehle im Timermenu'                         "$TIMERCMD" \
    'TIMERINFO'         'Zeigt ob ein Timer genug Platz hat'           "$TIMERINFO" \
    'TTXTSUBS'          'Teletext Plugin (ttxtsubs)'                   "$TTXTSUBS" \
    'VALIDINPUT'        'Eingabemoeglichkeiten mit < > anzeigen'       "$VALIDINPUT" \
    'VOLCTRL'           'Links/Rechts <> Lautstaerke Steuerung'        "$VOLCTRL" \
    'WAREAGLEICON'      'VDR-Symbole im OSD'                           "$WAREAGLEICON" \
    'YAEPG'             'Yet Another EPG'                              "$YAEPG"  3>&1 1>&2 2>&3`
    [ "$?" = "0" ] || return 1

    # reset patches
    ANALOGTV="off"
    ATSC="off"
    CHANNELSCAN="off"
    CMDRECCMDI18N="off"
    CMDSUBMENU="off"
    CUTTERLIMIT="off"
    CUTTERQUEUE="off"
    CUTTIME="off"
    DDEPGENTRY="off"
    DELTIMESHIFTREC="off"
    DOLBYINREC="off"
    DVBPLAYER="off"
    DVBSETUP="off"
    DVDARCHIVE="off"
    DVDCHAPJUMP="off"
    DVLFRIENDLYFNAMES="off"
    DVLRECSCRIPTADDON="off"
    DVLVIDPREFER="off"
    EM84XX="off"
    GRAPHTFT="off"
    HARDLINKCUTTER="off"
    JUMPPLAY="off"
    LIEMIEXT="off"
    LIRCSETTINGS="off"
    LIVEBUFFER="off"
    LNBSHARE="off"
    MAINMENUHOOKS="off"
    MENUORG="off"
    NOEPG="off"
    OSDMAXITEMS="off"
    PARENTALRATING="off"
    PINPLUGIN="off"
    PLUGINAPI="off"
    PLUGINMISSING="off"
    PLUGINPARAM="off"
    ROTOR="off"
    SETTIME="off"
    SETUP="off"
    SOFTOSD="off"
    SOURCECAPS="off"
    SORTRECORDS="off"
    STREAMDEVEXT="off"
    SYNCEARLY="off"
    TIMERCMD="off"
    TIMERINFO="off"
    TTXTSUBS="off"
    VALIDINPUT="off"
    VOLCTRL="off"
    WAREAGLEICON="off"
    YAEPG="off"

    # reactivate patches
    for i in $options; do
      eval ${i}="on"
    done
  fi

  # write to patchlevel.conf
  [ "$SETUP" = "on" ] && SUBMENU="off"
  [ "$MENUORG" = "on" ] && SETUP="off" && SUBMENU="off"
  {
    echo "## vdr patchlevel"
    echo "# Set Patchlevel to EXTENSIONS, PATCHES or PLAIN"
    echo ""
    echo "PATCHLEVEL=\"$PATCHLEVEL\""
    echo ""
    echo "## patches"
    echo "# plugin-patches will be added automaticly if a corresponding plugin is enabled in x-vdr"
    echo "# DVDCHAPJUMP needs DVDARCHIVE enabled"
    echo "# DVDARCHIVE needs LIEMIEXT enabled"
    echo "# SORTRECORDS needs LIEMIEXT enabled"
    echo "# you can only enable one of MENUORG SUBMENU SETUP"
    echo ""
    echo "ANALOGTV=\"$ANALOGTV\""
    echo "ATSC=\"$ATSC\""
    echo "CHANNELSCAN=\"$CHANNELSCAN\""
    echo "CMDRECCMDI18N=\"$CMDRECCMDI18N\""
    echo "CMDSUBMENU=\"$CMDSUBMENU\""
    echo "CUTTERLIMIT=\"$CUTTERLIMIT\""
    echo "CUTTERQUEUE=\"$CUTTERQUEUE\""
    echo "CUTTIME=\"$CUTTIME\""
    echo "DDEPGENTRY=\"$DDEPGENTRY\""
    echo "DELTIMESHIFTREC=\"$DELTIMESHIFTREC\""
    echo "DOLBYINREC=\"$DOLBYINREC\""
    echo "DVBPLAYER=\"$DVBPLAYER\""
    echo "DVBSETUP=\"$DVBSETUP\""
    echo "DVDARCHIVE=\"$DVDARCHIVE\""
    echo "DVDCHAPJUMP=\"$DVDCHAPJUMP\""
    echo "DVLFRIENDLYFNAMES=\"$DVLFRIENDLYFNAMES\""
    echo "DVLRECSCRIPTADDON=\"$DVLRECSCRIPTADDON\""
    echo "DVLVIDPREFER=\"$DVLVIDPREFER\""
    echo "EM84XX=\"$EM84XX\""
    echo "GRAPHTFT=\"$GRAPHTFT\""
    echo "HARDLINKCUTTER=\"$HARDLINKCUTTER\""
    echo "JUMPPLAY=\"$JUMPPLAY\""
    echo "LIEMIEXT=\"$LIEMIEXT\""
    echo "LIRCSETTINGS=\"$LIRCSETTINGS\""
    echo "LIVEBUFFER=\"$LIVEBUFFER\""
    echo "LNBSHARE=\"$LNBSHARE\""
    echo "MAINMENUHOOKS=\"$MAINMENUHOOKS\""
    echo "MENUORG=\"$MENUORG\""
    echo "NOEPG=\"$NOEPG\""
    echo "OSDMAXITEMS=\"$OSDMAXITEMS\""
    echo "PARENTALRATING=\"$PARENTALRATING\""
    echo "PINPLUGIN=\"$PINPLUGIN\""
    echo "PLUGINAPI=\"$PLUGINAPI\""
    echo "PLUGINMISSING=\"$PLUGINMISSING\""
    echo "PLUGINPARAM=\"$PLUGINPARAM\""
    echo "ROTOR=\"$ROTOR\""
    echo "SETTIME=\"$SETTIME\""
    echo "SETUP=\"$SETUP\""
    echo "SOFTOSD=\"$SOFTOSD\""
    echo "SOURCECAPS=\"$SOURCECAPS\""
    echo "SORTRECORDS=\"$SORTRECORDS\""
    echo "STREAMDEVEXT=\"$STREAMDEVEXT\""
    echo "SYNCEARLY=\"$SYNCEARLY\""
    echo "TIMERCMD=\"$TIMERCMD\""
    echo "TIMERINFO=\"$TIMERINFO\""
    echo "TTXTSUBS=\"$TTXTSUBS\""
    echo "VALIDINPUT=\"$VALIDINPUT\""
    echo "VOLCTRL=\"$VOLCTRL\""
    echo "WAREAGLEICON=\"$WAREAGLEICON\""
    echo "YAEPG=\"$YAEPG\""
    echo ""
  } > $XDIR/vdr/patchlevel.conf
  return 0
}

###########################################################

# installation oder update der libs mit apt-get
function start_apt() {
  cd $XDIR
  if [ "$1" = "--upgrade" ]; then
    if [ "$DIALOG" = "Xdialog" ]; then
      rxvt -title " $version - System wird aktualisiert... " -C -e ./apt.sh --upgrade
    else
      ./apt.sh --upgrade
    fi
    # fehlermeldung ?
    if [ -f $XDIR/.error ]; then
      ERROR=`cat $XDIR/.error`
      $DIALOG $d_args --title " $version - Fehler " --yesno \
        "Fehler in : \n$ERROR \n" $d_size
      [ $? = 0 ] && return 1
    fi
  else
    if [ "$DIALOG" = "Xdialog" ]; then
      rxvt -title " $version - System wird aktualisiert... " -C -e ./apt.sh
    else
      ./apt.sh
    fi
    # fehlermeldung ?
    if [ -f $XDIR/.error ]; then
      ERROR=`cat $XDIR/.error`
      $DIALOG $d_args --title " $version - Fehler " --yesno \
        "Fehler in : \n$ERROR \n\nSoll die Installation abgebrochen werden?" $d_size
      [ $? = 0 ] && return 1
    fi
  fi
  return 0
}

# VDR installieren
function start_vdr() {
  cd $XDIR/vdr
  if [ "$DIALOG" = "Xdialog" ]; then
    rxvt -title " $version - Erstellen des VDR " -C -e ./install-vdr.sh
  else
    ./install-vdr.sh
  fi
  # fehlermeldung ?
  if [ -f $XDIR/.error ]; then
    ERROR=`cat $XDIR/.error`
    $DIALOG $d_args --title " $version - Fehler " --msgbox "Fehler in \n$ERROR" $d_size
    log "ERROR - Installation des VDR fehlgeschlagen! "
    return 1
  fi
  return 0
}

# dvb driver
function start_dvb() {
  DVB_DRIVER=$1
  cd $XDIR/utilities/dvb/$DVB_DRIVER
  chmod 0744 ./dvb-driver.sh

  if [ -d "$SOURCEDIR/$DVB_DRIVER" ]; then
    $DIALOG $d_args --title " $version - $DVB_DRIVER " --yesno "$SOURCEDIR/$DVB_DRIVER gefunden. \nSollen die Quellen der DVB-Treiber entfernt werden?" $d_size
    [ $? = 0 ] || return 1
    if [ "$DIALOG" = "Xdialog" ]; then
      rxvt -title " $version - Entfernen der DVB-Treiber " -C -e ./dvb-driver.sh --clean
    else
      ./dvb-driver.sh --clean
    fi
  fi

  $DIALOG $d_args --title " $version - $DVB_DRIVER " --yesno "Sollen die DVB-Treiber jetzt erstellt werden?" $d_size
  [ $? = 0 ] || return 1
  cd $XDIR/utilities/dvb/$DVB_DRIVER
  if [ "$DIALOG" = "Xdialog" ]; then
     rxvt -title " $version - Erstellen der DVB-Treiber " -C -e ./dvb-driver.sh
  else
     ./dvb-driver.sh
  fi
}

# dvb firmware
function dvb_firmware_menu() {
  firmwaredir="/lib/firmware"
  option=`$DIALOG $d_args --ok-label "Start" --cancel-label "Back" --title " $version - DVB Firmware " --radiolist \
  'Welche Firmware soll installiert werden?' $d_size 6 \
  '1' 'FF-Karte fe2624 (dvb-ttpci-01.fw)'  'off' \
  '2' 'FF-Karte 2622 (dvb-ttpci-01.fw)'    'off' \
  '3' 'FF-Karte f12623 (dvb-ttpci-01.fw)'  'off' \
  '4' 'WinTV-HVR-4000 (dvb-fe-cx24116.fw)' 'off' \
  '5' 'andere ...'                         'off' 3>&1 1>&2 2>&3`
  [ $? = 0 ] || return 1
  case $option in
    1) [ -f $firmwaredir/dvb-ttpci-01.fw ] && cp -f $firmwaredir/dvb-ttpci-01.fw $firmwaredir/dvb-ttpci-01.fw.old
       WEB="http://www.escape-edv.de/endriss/firmware/dvb-ttpci-01.fw-fe2624"
       VAR=`basename $WEB`
       download_util
       cp -f $FILES/utilities/dvb-ttpci-01.fw-fe2624 $firmwaredir/dvb-ttpci-01.fw
       ;;
    2) [ -f $firmwaredir/dvb-ttpci-01.fw ] && cp -f $firmwaredir/dvb-ttpci-01.fw $firmwaredir/dvb-ttpci-01.fw.old
       WEB="http://linuxtv.org/downloads/firmware/dvb-ttpci-01.fw-2622"
       VAR=`basename $WEB`
       download_util
       cp -f $FILES/utilities/dvb-ttpci-01.fw-2622 $firmwaredir/dvb-ttpci-01.fw
       ;;
    3) [ -f $firmwaredir/dvb-ttpci-01.fw ] && cp -f $firmwaredir/dvb-ttpci-01.fw $firmwaredir/dvb-ttpci-01.fw.old
       WEB="http://www.suse.de/~werner/test_av-f12623.tar.bz2"
       VAR=`basename $WEB`
       download_util
       [ -d $SOURCEDIR/test_av ] && rm -rf $SOURCEDIR/test_av
       extract_util
       cp -f $SOURCEDIR/test_av/dvb-ttpci-01.fw $firmwaredir
       ;;
    4) [ -f $firmwaredir/dvb-fe-cx24116.fw ] && cp -f $firmwaredir/dvb-fe-cx24116.fw $firmwaredir/dvb-fe-cx24116.fw.old
       WEB=ftp://167.206.143.11/outgoing/Oxford/88x_2_119_25023_WHQL.zip
       VAR=`basename $WEB`
       download_util
       cd $FILES/utilities
       unzip -jo 88x_2_119_25023_WHQL.zip Driver88/hcw88bda.sys
       dd if=hcw88bda.sys of=/lib/firmware/dvb-fe-cx24116.fw skip=81768 bs=1 count=32522
       ;;
    5) [ -f $firmwaredir/dvb-ttpci-01.fw ] && cp -f $firmwaredir/dvb-ttpci-01.fw $firmwaredir/dvb-ttpci-01.fw.old
       option=`$DIALOG $d_args --title " $version - DVB Firmware " --inputbox \
       "Faengt die Zeile mit http:// an, versucht das Skript die Firmware aus dem Internet zu laden. Die Firmware wird dann nach $firmwaredir/dvb-ttpci-01.fw kopiert. Die Datei kann also auch anders heissen, wird aber nicht entpackt oder ueberprueft! " \
       $d_size "$HOME/dvb-ttpci-01.fw" 3>&1 1>&2 2>&3`
       if [ $? = 0 ]; then
         WEB=`echo "$option" | grep "^http://"`
         if [ -n "$WEB" ]; then
           VAR=`basename $WEB`
           download_util
           cp -f $FILES/utilities/$VAR $firmwaredir/dvb-ttpci-01.fw
         else
           [ -f "$option" ] && cp -f $option $firmwaredir/dvb-ttpci-01.fw
         fi
       fi
       ;;
  esac
  if [ -f $firmwaredir/dvb-ttpci-01.fw ]; then
    log "DVB-Firmware erfolgreich installiert"
  else
    log "DVB-Firmware konnte nicht installiert werden"
    [ -f $firmwaredir/dvb-ttpci-01.fw.old ] && cp -f $firmwaredir/dvb-ttpci-01.fw.old $firmwaredir/dvb-ttpci-01.fw
  fi
}

# dvb driver and firmware
function dvb_menu() {
  while true; do
    option=`$DIALOG $d_args --ok-label "Start" --cancel-label "Back" --title " $version - DVB Treiber und Firmware " --menu \
    'Aktiviere einen Menupunkt' $d_size 8 \
    '1' 'v4l-dvb' \
    '2' 's2-liplianin' \
    '3' 'multiproto_plus' \
    '4' 'multiproto' \
    '5' 'mantis' \
    '6' 'liplianindvb' \
    '7' 'Firmware Menu' 3>&1 1>&2 2>&3`
    [ $? != 0 ] && break
    # gewuenschte Funktion aufrufen
      case $option in
          1) start_dvb v4l-dvb ;;
          2) start_dvb s2-liplianin ;;
          3) start_dvb multiproto_plus ;;
          4) start_dvb multiproto ;;
          5) start_dvb mantis ;;
          6) start_dvb liplianindvb ;;
          7) dvb_firmware_menu ;;
      esac
  done
}

# utilities installieren
function start_utilities() {
  cmd="$1"
  utilities=`ls -l $SOURCEDIR/x-vdr/utilities`
  if [ -n "$utilities" ]; then
    [ "$cmd" = "--log" ] && echo "Installierte Utilities:" > $XDIR/utilities.txt
    for i in $utilities; do
      [ "$i" = "vidix" ] && i="xidiv"
      [ "$i" = "a_vidix" ] && i="vidix"
      if [ -x $XDIR/utilities/$i/utilitie.sh ]; then
        cd $XDIR/utilities/$i
        status=`./utilitie.sh --status`

        if [ "${!i}" = "off" ] && [ "$status" = "2" ]; then
          ./utilitie.sh --clean
        elif  [ "${!i}" = "on" ] && [ "$status" != "2" ]; then
          case "$status" in
            0) log "$i ist nicht installiert" && log "starte Installation" ;;
            1) log "$i ist installiert aber keine Sourcen in $SOURCEDIR" && log "eventuell liegt ein Fehler vor! " && log "starte erneute Installation" ;;
            2) log "Die x-vdr Version von $i ist installiert" ;;
            3) log "Die Debian Version von $i ist installiert" && log "starte erneute Installation" ;;
          esac

          if [ "$DIALOG" = "Xdialog" ]; then
            rxvt -title " $version - Erstellen von $i " -C -e ./utilitie.sh
          else
            ./utilitie.sh
          fi
        fi

        [ "$cmd" = "--log" ] && utilitie_check $i >> $XDIR/utilities.txt
      fi
    done
    if [ "$cmd" = "--log" ]; then
      status=`cat $XDIR/utilities.txt`
      rm $XDIR/utilities.txt
      $DIALOG $d_args --title " $version - Ergebnis der Installation " --msgbox "$status" $d_size
    fi
  fi
}

# plugins installieren
function start_plugins() {
  cd $XDIR
  if [ "$DIALOG" = "Xdialog" ]; then
    rxvt -title " $version - Erstellen der Plugins " -C -e ./plugins.sh
  else
    ./plugins.sh
  fi
}

# start strip
function start_strip() {
  log "Starte \"strip\""
  log ""
  cd $VDRBINDIR
  strip vdr
  cd $VDRLIBDIR
  LIBS=`ls`
  echo "$LIBS" | sed '/^[ ]*$/d' | while read i; do
    strip $i
  done
}

# start setup
function start_setup() {
  if [ "$set_vdrversion" = "on" ]; then
    sd_vdrversion
    [ $? != 0 ] && return 1
  fi
  if [ "$set_settings" = "on" ]; then
    sd_settings
    [ $? != 0 ] && return 1
  fi
  if [ "$set_dirs" = "on" ]; then
    sd_dirs
    [ $? != 0 ] && return 1
  fi
  if [ "$INS_UTILITIES" = "on" ]; then
    sd_utilities
    [ $? != 0 ] && return 1
  fi
  if [ "$INS_PLUGINS" = "on" ]; then
    sd_plugins
    [ $? != 0 ] && return 1
  fi
  if [ "$set_patchlevel" = "on" ]; then
    sd_patchlevel
    [ $? != 0 ] && return 1
  fi
  return 0
}

# show plugin status
function status() {
  status=`list_plugins`
  [ "$write_pluginslist" = "on" ] && echo "$status" > $XDIR/plugins.list
  if [ "$DIALOG" = "Xdialog" ]; then
    echo "$status" | $DIALOG $d_args --title " $version - Ergebnis der Installation " --no-cancel --textbox "-" $d_size
  else
    $DIALOG $d_args --title " $version - Ergebnis der Installation " --msgbox "$status" $d_size
  fi
}

# show utilitie status
function utilities_status() {
  status=`utilitie_check`
  [ "$write_utilitieslist" = "on" ] && echo "$status" > $XDIR/utilities.list
  if [ "$DIALOG" = "Xdialog" ]; then
    echo "$status" | $DIALOG $d_args --title " $version - Installierte Utilities " --no-cancel --textbox "-" $d_size
  else
    $DIALOG $d_args --title " $version - Installierte Utilities " --msgbox "$status" $d_size
  fi
}

# start installation
function start_install() {
  if [ -f $VDRPRG -o -f $SOURCEDIR/VDR/config.h ] && [ "$VDRUPDATE" = "off" ] && [ "$INSTALL_MODE" != "force" ]; then
    start_remove
    [ $? != 0 ] && return 1
  elif [ -f $VDRPRG -o -f $SOURCEDIR/VDR/config.h ] && [ "$VDRUPDATE" = "on" ]; then
    start_update
    [ $? != 0 ] && return 1
  else
    $DIALOG $d_args --title " $version - Installation " --yesno "Installation starten?" $d_size
    [ $? != 0 ] && return 1
  fi
  if [ "$INS_DVB" = "on" ]; then
    # can be one of liplianindvb, mantis, multiproto, multiproto_plus, s2-liplianin, v4l-dvb
    start_dvb v4l-dvb
    INS_DVB="off"
  fi
  if [ "$APT" = "on" ]; then
    start_apt
    [ $? != 0 ] && return 1
  fi
  if [ "$INS_VDR" = "on" ]; then
    start_vdr
    [ $? != 0 ] && return 1
  fi
  [ "$INS_UTILITIES" = "on" ] && start_utilities --nolog
  [ "$VDRUPDATE" = "on" ] && [ "$INS_PLUGINS" = "off" ] && cp -rf /tmp/PLUGINS $SOURCEDIR/VDR
  [ "$INS_PLUGINS" = "on" ] && start_plugins
  [ "$STRIP" = "on" ] && start_strip
  status
}

# start direct installation
function start_direct_install() {
  VDRUPDATE="off"
  INSTALL_MODE="force"
  sd_write
  if [ "$APT" = "on" ]; then
    start_apt
    [ $? != 0 ] && return 1
  fi
  if [ -f $VDRPRG ]; then
    backup_vdr_bin
    backup_vdr_src
    clean_vdr
    clean_vdr_src
  fi
  if [ "$INS_VDR" = "on" ]; then
    start_vdr
    [ $? != 0 ] && return 1
  fi
  [ "$INS_UTILITIES" = "on" ] && start_utilities --nolog
  if [ "$INS_PLUGINS" = "on" ]; then
    cd $XDIR
    ./plugins.sh
  fi
  [ "$STRIP" = "on" ] && start_strip
  list_plugins
  exit 0
}

# remove vdr & vdr-src
function start_remove() {
  # dialog
  options=`$DIALOG $d_args --separate-output --title " $version - Backup & Remove " --checklist \
  'Der VDR wird nun entfernt.' $d_size 4 \
  '1' 'Backup von VDR + Plugins + Skripte + Konfiguration' 'on' \
  '2' 'Backup der VDR Sourcen' 'off' \
  '3' 'Backup der Skripte und der Konfiguration' 'off' 3>&1 1>&2 2>&3`
  if [ $? = 0 ]; then
    if [ -n "$options" ]; then
      x=0
      for i in $options; do
        let x=$x+2
      done
      n=0
      for i in $options; do
        let n=$n+1
        echo $(($n * 100 / $x))
        case "$i" in
          1) echo XXX; echo "... VDR + Plugins + Skripte + Konfiguration "; echo XXX; backup_vdr_bin ;;
          2) echo XXX; echo "... VDR Sourcen "; echo XXX; backup_vdr_src ;;
          3) echo XXX; echo "... Skripte und der Konfiguration "; echo XXX; backup_vdr_conf ;;
        esac
        let n=$n+1
        echo $(($n * 100 / $x))
        sleep 2
      done | $DIALOG $d_args --title " $version - Erstelle Sicherung ... " --gauge "" $d_size 0
    fi
    clean_vdr
    clean_vdr_src
  else
    return 1
  fi
}

# remove vdr & vdr-src
function start_update() {
  # dialog
  options=`$DIALOG $d_args --separate-output --title " $version - Update & Backup " --checklist \
  'Das Update wird nun durchgefuehrt.' $d_size 4 \
  '1' 'Backup von VDR + Plugins + Skripte + Konfiguration' 'on' \
  '2' 'Backup der VDR Sourcen' 'off' \
  '3' 'Backup der Skripte und der Konfiguration' 'off' 3>&1 1>&2 2>&3`
  if [ $? = 0 ]; then
    if [ -n "$options" ]; then
      x=0
      for i in $options; do
        let x=$x+2
      done
      n=0
      for i in $options; do
        let n=$n+1
        echo $(($n * 100 / $x))
        case "$i" in
          1) echo XXX; echo "... VDR + Plugins + Skripte + Konfiguration "; echo XXX; backup_vdr_bin ;;
          2) echo XXX; echo "... VDR Sourcen "; echo XXX; backup_vdr_src ;;
          3) echo XXX; echo "... Skripte und der Konfiguration "; echo XXX; backup_vdr_conf ;;
        esac
        let n=$n+1
        echo $(($n * 100 / $x))
        sleep 2
      done | $DIALOG $d_args --title " $version - Erstelle Sicherung ... " --gauge "" $d_size 0
    fi
    if [ "$INS_PLUGINS" = "off" ]; then
      [ -d /tmp/PLUGINS ] && rm -rf /tmp/PLUGINS
      cp -r $SOURCEDIR/VDR/PLUGINS /tmp
    else
      rm -rf $VDRLIBDIR/*
    fi
    clean_vdr_src
    rm -f $VDRPRG
  else
    return 1
  fi
}

## backup menu
function start_backup() {
  options=`$DIALOG $d_args --separate-output --title " $version - Backup " --checklist \
  'Aktiviere deine Optionen' $d_size 4 \
  '1' 'Backup von VDR + Plugins + Skripte + Konfiguration' 'on' \
  '2' 'Backup der VDR Sourcen' 'off' \
  '3' 'Backup der Skripte und der Konfiguration' 'off' 3>&1 1>&2 2>&3`
  if [ $? = 0 ] && [ -n "$options" ]; then
    x=0
    for i in $options; do
      let x=$x+2
    done
    n=0
    for i in $options; do
      let n=$n+1
      echo $(($n * 100 / $x));
      case "$i" in
          1) echo XXX; echo "... VDR + Plugins + Skripte + Konfiguration "; echo XXX; backup_vdr_bin ;;
          2) echo XXX; echo "... VDR Sourcen "; echo XXX; backup_vdr_src ;;
          3) echo XXX; echo "... Skripte und der Konfiguration "; echo XXX; backup_vdr_conf ;;
      esac
      let n=$n+1
      echo $(($n * 100 / $x))
      sleep 2
    done | $DIALOG $d_args --title " $version - Erstelle Sicherung ... " --gauge "" $d_size 0
  fi
}

# reactivate vdr from backup.tar
function start_reactivate() {
  backups=$(ls $BACKUPPATH/*-*-vdr-*.tar.gz)
  if [ -n "$backups" ]; then
    bups=
    n=1
    for i in $backups; do
      if [ "$DIALOG" = "Xdialog" ]; then
        var="$(basename $i)"
        tags="--no-tags"
      else
        var=":"
        tags=""
      fi
      bups="$bups $(basename $i) $var off "
      (( n=$n+1 ))
    done
    (( $n > 12 )) && n=12
    options=`$DIALOG $d_args $tags --separate-output --title " $version - Update & Backup " --checklist \
    'Welche Backups sollen zurueck gespielt werden?' $d_size $n \
    $bups 3>&1 1>&2 2>&3`
    if [ $? = 0 ]; then
      for i in $options; do
        case "$i" in
          *vdr-bin.tar.gz) clean_vdr; tar -xzpf $BACKUPPATH/$i -C / && make_dirs && log "$i entpackt" && make_autostart ;;
          *vdr-src.tar.gz) clean_vdr_src; tar -xzpf $BACKUPPATH/$i -C / && log "$i entpackt";;
          *vdr-conf.tar.gz) clean_vdr_conf; tar -xzpf $BACKUPPATH/$i -C / && log "$i entpackt";;
        esac
      done
    fi
  fi
}

# reactivate vdr from backup.tar
function start_backup_remove() {
  backups=$(ls $BACKUPPATH/*-*-vdr-*.tar.gz)
  if [ -n "$backups" ]; then
    bups=
    n=1
    for i in $backups; do
      if [ "$DIALOG" = "Xdialog" ]; then
        var="$(basename $i)"
        tags="--no-tags"
      else
        var=":"
        tags=""
      fi
      bups="$bups $(basename $i) $var off "
      (( n=$n+1 ))
    done
    (( $n > 12 )) && n=12
    options=`$DIALOG $d_args $tags --separate-output --title " $version - Backups verwalten " --checklist \
      'Welche Backups sollen entfernt werden?' $d_size $n \
      $bups 3>&1 1>&2 2>&3`
    if [ $? = 0 ]; then
      for i in $options; do
        rm -f $BACKUPPATH/$i && log "$i entfernt"
      done
    fi
  fi
}

function backup_menu() {
  while true; do
    option=`$DIALOG $d_args --ok-label "Start" --cancel-label "Back" --title " $version - Backup Menu " --menu \
    'Aktiviere einen Menupunkt' $d_size 5 \
    '1' 'Backup des VDR erstellen' \
    '2' 'Backup zurueck spielen' \
    '3' 'Backups verwalten' \
    '4' 'VDR entfernen' 3>&1 1>&2 2>&3`
    [ $? != 0 ] && break
    # gewuenschte Funktion aufrufen
      case $option in
          1) start_backup ;;
          2) start_reactivate ;;
          3) start_backup_remove ;;
          4) start_remove ;;
      esac
  done
}

# show license
function license() {
  if [ "$DIALOG" = "Xdialog" ]; then
    $DIALOG $d_args --title " $version - GNU GENERAL PUBLIC LICENSE " --no-cancel --textbox "$XDIR/gpl.txt" $d_size
  else
    status=`cat $XDIR/gpl.txt`
    $DIALOG $d_args --title " $version - GNU GENERAL PUBLIC LICENSE " --msgbox "$status" $d_size
  fi
}
# show readme
function readme() {
  if [ "$DIALOG" = "Xdialog" ]; then
    $DIALOG $d_args --title " $version - README " --no-cancel --textbox "$XDIR/docs/help.txt" $d_size
  else
    status=`cat $XDIR/docs/help.txt`
    $DIALOG $d_args --title " $version - README " --msgbox "$status" $d_size
  fi
}

# set chmod
function set_chmod() {
  chmod 0744 $XDIR/apt.sh
  chmod 0744 $XDIR/plugins.sh
  chmod 0744 $XDIR/plugins/*/plugin.sh
  chmod 0744 $XDIR/utilities/*/utilitie.sh
  chmod 0744 $XDIR/vdr/install-vdr.sh
  chmod 0744 $XDIR/vdr/make-conf.sh
}

# visudo
function check_sudoers() {
  if [ "$VDRUSER" != "root" ] && [ -x $VDRPRG ]; then
    sudoers=`grep "$VDRUSER" /etc/sudoers`
    if [ ! -n "$sudoers" ]; then
      $DIALOG $d_args --title " $version - sudoers " --yesno \
      "Da der VDR nicht vom Superuser \"root\" gestartet wird, ist es notwendig den VDRUSER \"$VDRUSER\" in /etc/sudoers einzutragen. \nDer Eintrag sollte so aussehen:\nroot    ALL=(ALL) ALL \n$VDRUSER ALL=NOPASSWD: $VDRSCRIPTDIR/vdr2root, $VDRSCRIPTDIR/vdrsetup, $VDRSCRIPTDIR/vdrmount, /bin/ln \n\nDie Bedienung von visudo: \ni = Einfuegen starten \nesc = Einfuegen beenden \n:q = beenden \n:wq = speichern und beenden \n\nSoll visudo jetzt gestartet werden?" $d_size
      [ $? != 0 ] && return 0
      if [ "$DIALOG" = "Xdialog" ]; then
        rxvt -title " $version - visudo " -C -e visudo
      else
        visudo
      fi
    fi
  fi
}

function edit_sudoers() {
  if [ "$DIALOG" = "Xdialog" ]; then
    rxvt -title " $version - visudo " -C -e visudo
  else
    visudo
  fi
}

# presets
function PresetMenu() {
  presets=$(ls $XDIR/presets/*)
  if [ -n "$presets" ]; then
    pres=
    var=
    n=1
    for i in $presets; do
      pres="$pres $(basename $i) ."
      (( n=$n+1 ))
    done
    (( $n > 12 )) && n=12
    option=`$DIALOG $d_args --ok-label "Start" --cancel-label "Back" --title " $version - Presets " --menu \
    'Welches Voreinstellung soll aktiviert werden?' $d_size $n \
    $pres 3>&1 1>&2 2>&3`
    if [ $? = 0 ]; then
      last_setup="backup-$(date '+%F_%T')"
      cp -f $XDIR/setup.conf $XDIR/$last_setup
      source $XDIR/presets/$option && sd_write
      rm -f $XDIR/presets/backup-*
      mv -f $XDIR/$last_setup $XDIR/presets
      $DIALOG $d_args --title " $version - Presets " --msgbox "$last_setup wurde angelegt.\n$option wurde aktiviert." $d_size
    fi
  else
    last_setup="backup-$(date '+%F_%T')"
    cp -f $XDIR/setup.conf $XDIR/presets/$last_setup
    $DIALOG $d_args --title " $version - Presets " --msgbox "Es wurden keine Presets gefunden!\n$last_setup wurde angelegt." $d_size
    return 1
  fi
}

# pluginmenu config
function PluginMenuConfig() {
    # de-activate plugin
    if [ "$plugin_config" = "on" ] && [ "$plugin_val_old" != "fatal error" ] && [ -n "$plugin_val" ]; then
      option=`$DIALOG $d_args --title " $version - Plugin: $plugin_name " --radiolist \
      "Plugin An- oder Abschalten" $d_size 3 \
      '1' "$plugin_val_old" 'on' \
      '2' "$plugin_val_new" 'off' 3>&1 1>&2 2>&3`
      if [ $? = 0 ]; then
        case $option in
          2) sed -i /etc/default/vdr -e "s/^$plugin_val/$plugin_name=\"$plugin_val_new\"/g" ;;
          *) plugin_val_new="$plugin_val_old" ;;
        esac
      else
        plugin_val_new="$plugin_val_old"
      fi
    elif [ "$plugin_auto_config" = "on" ] && [ -n "$plugin_val" ]; then
      case "$plugin_status" in
        1) plugin_val_new="on"  ;;
        *) plugin_val_new="off" ;;
      esac
      if [ "$plugin_val_new" != "$plugin_val_old" ]; then
        sed -i /etc/default/vdr -e "s/^$plugin_val/$plugin_name=\"$plugin_val_new\"/g"
      fi
    elif [ "$plugin_auto_config" = "on" ]; then
      case "$plugin_status" in
        1) plugin_val_new="on"  ;;
        *) plugin_val_new="off" ;;
      esac
      echo "" >> /etc/default/vdr
      echo "# $plugin" >> /etc/default/vdr
      echo "$plugin=\"$plugin_val_new\"" >> /etc/default/vdr
    else
      plugin_val_new="$plugin_val_old"
    fi

    # plugin arguments
    plugin_args_new=
    if [ "$plugin_config" = "on" ] && [ "$plugin_val_new" = "on" ] && [ -n "$plugin_args" ]; then
#      plugin_args_old=$(echo $plugin_args | cut -f 2 -d '=' | sed -e "s/\"//g")
      plugin_args_old=$(echo "$plugin_args" | sed -e "s/^${plugin}_args=//" -e 's/"//g' -e 's/#.*//')
      option=`$DIALOG $d_args --title " $version - Plugin: $plugin_name " \
      --inputbox "Plugin Argumente:" $d_size "$plugin_args_old" 3>&1 1>&2 2>&3`
      if [ $? = 0 ]; then
        plugin_args_new="${plugin_name}_args=\"$option\""
        sed -i /etc/default/vdr -e "s?^$plugin_args?$plugin_args_new?g"
      else
        plugin_args_new="$plugin_args"
      fi
    fi

    # status message
    current_version="$($VDRPRG --version | grep "^${plugin}[- ]" | tail -n1 | cut -d ")" -f 1 | sed -e 's/(//' -e 's/-client / /')"
    if [ -z "$current_version" ] && [ "$plugin_status" = "1" ]; then
      current_version="something went wrong!"
    elif [ -z "$current_version" ]; then
      current_version="$p_status"
    fi
    $DIALOG $d_args --title " $version - Plugin: $plugin_name " \
    --msgbox "${plugin_desc}Version (im Skript): $plugin_version \nInstallierte Version: $current_version \nKonfiguration: \n$plugin_name=\"$plugin_val_new\" \n$plugin_args_new" $d_size
}

# pluginmenu
function PluginMenu() {
  write_to_setup="off"
  # dialog (plugin auswahl)
  xPlugins -m
  option=`$DIALOG $d_args --ok-label "Start" --cancel-label "Back" --title " $version - Plugin Menu " --menu \
  'Aktiviere das Plugin, das du bearbeiten moechtest mit Enter. \nMit "aktiv" bzw. "inaktiv" wird der Status der Plugins angezeigt.' $d_size 12 \
  $plugin_list  3>&1 1>&2 2>&3`

  if [ $? = 0 ] && [ -x $XDIR/plugins/$option/plugin.sh ]; then
    plugin=$option
    cd $XDIR/plugins/$plugin
    plugin_version=`./plugin.sh --version`
    plugin_status=`./plugin.sh --status`
    case "$plugin_status" in
      0) p_status="not installed" ;;
      1) p_status="installed" ;;
      *) p_status="error" ;;
    esac

    plugin_config="off"
    plugin_name="$plugin"
    [ "$plugin" = "streamdev" ] && plugin_name="streamdev_server"

    var="${plugin}_desc"
    if [ -n "${!var}" ]; then
      plugin_desc="${!var}\n"
    else
      plugin_desc=""
    fi

    # filter plugin settings from /etc/default/vdr
    if [ -f /etc/default/vdr ]; then
      plugin_val=$(grep "^${plugin_name}=" /etc/default/vdr | tail -n1)
      plugin_val_old=$(echo $plugin_val | cut -f 2 -d '=')
      plugin_val_old=$(eval echo $plugin_val_old)
      case "$plugin_val_old" in
        on)  plugin_val_old="on";    plugin_val_new="off" ;;
        off) plugin_val_old="off";   plugin_val_new="on" ;;
        *)   plugin_val_old="error"; plugin_val_new="off" ;;
      esac
      plugin_args=$(grep "^${plugin_name}_args=" /etc/default/vdr | tail -n1)
    else
      plugin_val_old="fatal error"
    fi

    if [ "$plugin_status" = "0" ]; then # show menu
      option=`$DIALOG $d_args --ok-label "Start" --cancel-label "Back" --title " $version - Plugin: $plugin " --radiolist \
      "${plugin_desc}Version (im Skript): $plugin_version \nStatus: $p_status \nKonfiguration:  \n$plugin_name=\"$plugin_val_old\" \n$plugin_args" $d_size 4 \
      '1' 'Plugin installieren'  'off' \
      '2' 'Plugin konfigurieren' 'off' \
      '3' 'plugin.sh bearbeiten' 'off' 3>&1 1>&2 2>&3`
      if [ $? = 0 ]; then
        case $option in
          1) if [ "$DIALOG" = "Xdialog" ]; then
               rxvt -title " $version - Plugin $i " -C -e ./plugin.sh --make
             else
               ./plugin.sh --make
             fi
             write_to_setup="on" ;;
          2) plugin_config="on" ;;
          3) $d_browser "$XDIR/plugins/$plugin" ;;
        esac
      else
        return 0
      fi
    else # show another menu
      current_version="$($VDRPRG --version | grep "^${plugin}[- ]" | tail -n1 | cut -d ")" -f 1 | sed -e 's/(//' -e 's/-client / /')"
      if [ -z "$current_version" ] && [ "$plugin_status" = "1" ]; then
        current_version="something went wrong!"
      elif [ -z "$current_version" ]; then
        current_version="$p_status"
      fi
      option=`$DIALOG $d_args --ok-label "Start" --cancel-label "Back" --title " $version - Plugin: $plugin " --radiolist \
      "${plugin_desc}Version (im Skript): $plugin_version \nInstallierte Version: $current_version \nKonfiguration:  \n$plugin_name=\"$plugin_val_old\" \n$plugin_args" $d_size 5 \
      '1' 'Plugin entfernen'           'off' \
      '2' 'Plugin erneut installieren' 'off' \
      '3' 'Plugin konfigurieren'       'off' \
      '4' 'plugin.sh bearbeiten'       'off' 3>&1 1>&2 2>&3`
      if [ $? = 0 ]; then
        case $option in
          1) ./plugin.sh --clean ; write_to_setup="on" ;;
          2) if [ "$DIALOG" = "Xdialog" ]; then
               rxvt -title " $version - Plugin $i " -C -e ./plugin.sh --remake
             else
               ./plugin.sh --remake
             fi
             write_to_setup="on" ;;
          3) plugin_config="on" ;;
          4) $d_browser "$XDIR/plugins/$plugin" ;;
        esac
      else
        return 0
      fi
    fi

    # write to setup.conf
    if [ "$write_to_setup" = "on" ]; then
      plugin_status=`./plugin.sh --status`
      case "$plugin_status" in
        0) p_status="not installed"; eval $plugin=off ;;
        1) p_status="installed";     eval $plugin=on ;;
        *) p_status="error";         eval $plugin=off ;;
      esac
      sd_write
    fi

    # write to /etc/default/vdr
    PluginMenuConfig

    # install sub-plugins
    subplugins=""
    case "$plugin" in
      epgsearch)       [ "$plugin_val_new" = "on" ] && subplugins="epgsearchonly conflictcheckonly quickepgsearch" ;;
      streamdev)       subplugins="streamdev_client" ;;
      mp3|mp3ng|music) subplugins="mplayer" ;;
    esac

    if [ -f /etc/default/vdr ]; then
      for plugin_name in $subplugins; do
        plugin_val=$(grep "^${plugin_name}=" /etc/default/vdr | tail -n1)
        plugin_val_old=$(echo $plugin_val | cut -f 2 -d '=')
        plugin_val_old=$(eval echo $plugin_val_old)
        case "$plugin_val_old" in
          on)  plugin_val_old="on";    plugin_val_new="off" ;;
          off) plugin_val_old="off";   plugin_val_new="on" ;;
          *)   plugin_val_old="error"; plugin_val_new="off" ;;
        esac
        plugin_args=$(grep "^${plugin_name}_args=" /etc/default/vdr | tail -n1)
        var="${plugin_name}_desc"
        if [ -n "${!var}" ]; then
          plugin_desc="${!var}\n"
        else
          plugin_desc=""
        fi
        PluginMenuConfig
      done
    else
      plugin_val_old="fatal error"
    fi
  else
    return 1
  fi
  return 0
}

# fonts
function FontsMenu() {
  while true; do
    option=`$DIALOG $d_args --ok-label "Start" --cancel-label "Back" --title " $version - Fonts Menu " --menu \
    "Aktiviere einen Menupunkt" $d_size 5 \
    '1' "VDR Fonts installieren" \
    '2' "Locales konfigurieren" \
    '3' "Locales generieren" \
    '4' "fix-fonts ausfuehren"  3>&1 1>&2 2>&3`
    [ $? != 0 ] && break
    # gewuenschte Funktion aufrufen
    case $option in
      1) vdrfonts="on"
         cd $XDIR/utilities/vdrfonts
         ./utilitie.sh ;;
      2) [ -x /usr/sbin/dpkg-reconfigure ] || return 1
         if [ "$DIALOG" = "Xdialog" ]; then
           rxvt -title " $version - Locales konfigurieren " -C -e /usr/sbin/dpkg-reconfigure locales
         else
           /usr/sbin/dpkg-reconfigure locales
         fi ;;
      3) [ -x /usr/sbin/locale-gen ] && /usr/sbin/locale-gen ;;
      4) [ -x /usr/sbin/fix-fonts ] && /usr/sbin/fix-fonts ;;
    esac
  done
}

# installmenu
function install_menu() {
  while true; do
    option=`$DIALOG $d_args --ok-label "Start" --cancel-label "Back" --title " $version - Installations Menu " --menu \
    'Aktiviere einen Menupunkt' $d_size 12 \
    '1' 'Einstellungen' \
    '2' 'VDR Version aendern' \
    '3' 'Patchlevel' \
    '4' 'Plugins' \
    '5' 'Plugins verwalten' \
    '6' 'Liste der installierten Plugins' \
    '7' 'Utilities' \
    '8' 'DVB Treiber und Firmware' \
    '9' 'Verzeichnisse aendern' \
   '10' 'Setup als Konfiguration speichern'\
   '11' 'Installation starten' \
   '12' 'VDR entfernen'  3>&1 1>&2 2>&3`
    [ $? != 0 ] && break
    # gewuenschte Funktion aufrufen
    case $option in
      1) sd_settings && make_autostart && config_flag="on" ;;
      2) sd_vdrversion && [ "$INS_DVB" = "on" ] && dvb_menu ;;
      3) sd_patchlevel ;;
      4) sd_plugins && start_plugins && config_flag="on" && status ;;
      5) while true; do PluginMenu; [ $? != 0 ] && break; done ;;
      6) status ;;
      7) sd_utilities && start_utilities --log && config_flag="on" ;;
      8) dvb_menu ;;
      9) sd_dirs && make_dirs && config_flag="on" ;;
     10) sd_write ; make_default ;;
     11) sd_update && start_install && config_flag="on" ;;
     12) start_remove ;;
    esac
  done
  [ "$AUTO_CONFIG" = "on" ] && [ "$config_flag" = "on" ] && make_default
}

# vdr-setupmenu
function vdr_setup_menu() {
  while true; do
    option=`$DIALOG $d_args --ok-label "Start" --cancel-label "Back" --title " $version - VDR-Setup Menu " --menu \
    "Aktiviere einen Menupunkt" $d_size 7 \
    '1' "$VDRCONFDIR mit $d_browser oeffnen" \
    '2' "$VDRSCRIPTDIR mit $d_browser oeffnen" \
    '3' "/etc/default/vdr mit $d_editor editieren" \
    '4' "/etc/init.d/vdr mit $d_editor editieren" \
    '5' "$VDRBINDIR/runvdr mit $d_editor editieren" \
    '6' 'Setup als Konfiguration speichern' 3>&1 1>&2 2>&3`
    [ $? != 0 ] && break
    # gewuenschte Funktion aufrufen
    case $option in
      1) $d_browser "$VDRCONFDIR" ;;
      2) $d_browser "$VDRSCRIPTDIR" ;;
      3) [ -f /etc/default/vdr ] && $d_editor /etc/default/vdr ;;
      4) [ -f /etc/init.d/vdr ] && $d_editor /etc/init.d/vdr ;;
      5) [ -f "$VDRBINDIR/runvdr" ] && $d_editor "$VDRBINDIR/runvdr" ;;
      6) sd_write ; make_default ;;
    esac
  done
}

# systemmenu
function system_menu() {
  while true; do
    option=`$DIALOG $d_args --ok-label "Start" --cancel-label "Back" --title " $version - System Menu " --menu \
    'Aktiviere einen Menupunkt' $d_size 10 \
    '1' 'Sidux Kontrollzentrum starten' \
    '2' 'Netzwerk konfigurieren' \
    '3' 'Fonts und Locales' \
    '4' 'System aktualisieren (apt.sh)' \
    '5' 'System aktualisieren (apt.sh --upgrade)' \
    '6' "$SOURCEDIR mit $d_browser oeffnen" \
    '7' "fstab mit $d_editor editieren" \
    '8' "lilo.conf mit $d_editor editieren" \
    '9' "sudoers mit visudo editieren" 3>&1 1>&2 2>&3`
    [ $? != 0 ] && break
    # gewuenschte Funktion aufrufen
    case $option in
      1) if [ "$DIALOG" = "Xdialog" ]; then
           [ -x /usr/bin/siduxcc-kde ] && /usr/bin/siduxcc-kde
         else
           [ -x /usr/bin/siduxcc ] && /usr/bin/siduxcc
         fi ;;
      2) if [ -x /usr/bin/ceni ]; then
           if [ "$DIALOG" = "Xdialog" ]; then
             rxvt -title " $version - Netzwerk konfigurieren " -C -e /usr/bin/ceni
           else
             /usr/bin/ceni
           fi
         else
           netcardconfig
         fi ;;
      3) FontsMenu ;;
      4) start_apt ;;
      5) start_apt --upgrade ;;
      6) $d_browser "$SOURCEDIR" ;;
      7) [ -f /etc/fstab ] && $d_editor /etc/fstab ;;
      8) [ -f /etc/lilo.conf ] && $d_editor /etc/lilo.conf ;;
      9) [ -f /etc/sudoers ] && edit_sudoers ;;
    esac
  done
}

# exitmenu
function exit_menu() {
  case $exit_option in
    0) e_option="keine" ;;
    1) e_option="VDR starten" ;;
    2) e_option="VDR neu starten" ;;
    3) e_option="System neu starten" ;;
    4) e_option="System ausschalten" ;;
  esac
  option=`$DIALOG $d_args --title " $version - Exit Menu " --menu \
  "Aktiviere deine Option \nDie Aktion wird erst beim normalen beenden ausgefuehrt! \nAktuelle Einstellung: \"$e_option\"" $d_size 6 \
  '0' 'keine' \
  '1' 'VDR starten' \
  '2' 'VDR neu starten' \
  '3' 'System neu starten' \
  '4' 'System ausschalten' 3>&1 1>&2 2>&3`
  [ $? != 0 ] && return 0
  # exit option setzen
  case $option in
    0) exit_option="0" ;;
    1) exit_option="1" ;;
    2) exit_option="2" ;;
    3) exit_option="3" ;;
    4) exit_option="4" ;;
  esac
}

### Main ###################################################################################

# working dir
[ ! -f $XDIR/x-vdr.conf ] && XDIR=/usr/local/src/x-vdr
[ ! -f $XDIR/x-vdr.conf ] && XDIR=`dirname $0`

# include x-vdr.conf - default settings
if [ ! -f $XDIR/x-vdr.conf ]; then
  echo "Fehler! x-vdr.conf nicht gefunden."
  $0 --help
  echo "x-vdr wird jetzt beendet."
  echo ""
  exit 1
else
  source $XDIR/x-vdr.conf
fi

# include setup.conf - user settings
setup_file="$XDIR/setup.conf"
if [ -f $setup_file ]; then
  source $setup_file
  LINUXVERSION=""
  INSTALL_MODE=""
else
  sd_start
fi

# include functions
source $XDIR/functions

# if there is no setup.conf -> create one
[ ! -f $setup_file ] && sd_write

# verify_input
AUTOSTART=`verify_input "$AUTOSTART"`
XPLAYER=`verify_input "$XPLAYER"`
APT=`verify_input "$APT"`
INS_UTILITIES=`verify_input "$INS_UTILITIES"`
INS_VDR=`verify_input "$INS_VDR"`
INS_PLUGINS=`verify_input "$INS_PLUGINS"`
INS_USER=`verify_input "$INS_USER"`
STRIP=`verify_input "$STRIP"`
USELIRC=`verify_input "$USELIRC"`
USEVFAT=`verify_input "$USEVFAT"`
VDRUPDATE=`verify_input "$VDRUPDATE"`
verify_utilities
xPlugins

 # vdr stop
if [ "$config_mode" != "on" ]; then
  [ -n "`pidof -sx runvdr`" ] && killall -9 runvdr && echo "beende runvdr"
  [ -n "`pidof -sx vdr`" ] && killall -9 vdr && echo "beende VDR"
fi

# symlinks
if [ ! -d $SOURCEDIR/x-vdr ]; then
  cd $SOURCEDIR
  ln -vnfs $XDIR x-vdr
  cd $XDIR
fi

if [ ! -f /usr/local/bin/x-vdr ]; then
  cd /usr/local/bin
  ln -vnfs $XDIR/x-vdr.sh x-vdr
  cd $XDIR
fi

# Verzeichnisse erstellen?
[ ! -d "$FILES" ] && mkdir -p $FILES && log "erstelle \"$FILES\""
[ ! -d "$FILES/plugins" ] && mkdir -p "$FILES/plugins" && log "erstelle \"$FILES/plugins\""
[ ! -d "$FILES/utilities" ] && mkdir -p "$FILES/utilities" && log "erstelle \"$FILES/utilities\""
[ ! -d "$FILES/vdr" ] && mkdir -p "$FILES/vdr" && log "erstelle \"$FILES/vdr\""
[ ! -d "$XDIR/presets" ] && mkdir -p "$XDIR/presets" && log "erstelle \"$XDIR/presets\""

# skripte ausfuehrbar machen
set_chmod

# direct install and exit
[ "$direct_install" = "on" ] && start_direct_install

# sidux installed ?
sd_linuxversion

# main menu
while true; do
  cd $XDIR
  # Start-Fenster-Schleife
  option=`$DIALOG $d_args --ok-label "Start" --cancel-label "Exit" --title " $version - Start Menu " --menu \
  'Aktiviere einen Menupunkt' $d_size 9 \
  '1' 'Interaktive Installation' \
  '2' 'Installations Menu' \
  '3' 'Backup Menu' \
  '4' 'System Menu' \
  '5' 'VDR-Setup Menu' \
  '6' 'Preset Menu' \
  '7' 'Exit Menu' \
  '8' 'Hilfe' 3>&1 1>&2 2>&3`
  [ $? != 0 ] && break
  # gewuenschte Funktion aufrufen
    case $option in
      1) sd_update && start_setup && start_install && [ "$AUTO_CONFIG" = "on" ] && make_default ;;
      2) install_menu ;;
      3) backup_menu ;;
      4) system_menu ;;
      5) vdr_setup_menu ;;
      6) PresetMenu ;;
      7) exit_menu ;;
      8) readme ;;
    esac
done
clear

# visudo
check_sudoers
clear

# Exit Option aufrufen
case $exit_option in
  1) if [ "$AUTOSTART" = "on" ]; then
       /etc/init.d/vdr start
     else
       runvdr &
       echo "starte VDR"
     fi ;;
  2) if [ "$AUTOSTART" = "on" ]; then
       /etc/init.d/vdr restart
     else
       killall -9 runvdr
       killall -9 vdr
       echo "beende VDR"
       sleep 5
       runvdr &
       echo "starte VDR"
     fi ;;
  3) shutdown -r now ;;
  4) shutdown -h now ;;
esac

exit 0


