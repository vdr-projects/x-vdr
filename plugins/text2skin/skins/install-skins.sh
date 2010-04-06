#!/bin/sh

# x-vdr (Installations-Skript fuer einen VDR mit Debian als Basis)
# von Marc Wernecke - www.zulu-entertainment.de
# 08.12.2006

# skins fuer text2skin

source ./../../../x-vdr.conf
source ./../../../setup.conf
source ./../../../functions

# remove old skins
if [ -d "$VDRCONFDIR/plugins/text2skin" ]; then
  rm -rf "$VDRCONFDIR/plugins/text2skin"
fi

if [ ! -d "$VDRCONFDIR/plugins/text2skin/fonts" ]; then
  mkdir -p "$VDRCONFDIR/plugins/text2skin/fonts" && log "Erstelle \"$VDRCONFDIR/plugins/text2skin/fonts\""
fi

if [ -n "$SKINS" ]; then
  echo "$SKINS" | sed '/^[ ]*$/d' | while read i; do
    VAR=`basename $i`
    if [ -f "$FILES/plugins/$VAR" ]; then
      log "$VAR gefunden"
    elif [ -f "$VAR" ]; then
      log "$VAR gefunden"
      cp "$VAR" "$FILES/plugins"
    else
      log "$VAR nicht gefunden"
      log "starte download"
      if wget --tries=2 "$i" --directory-prefix="$FILES/plugins" &>/dev/null; then
        log "Download von $VAR erfolgreich"
      else
        log "Download von $VAR nicht erfolgreich"
      fi
    fi

    if [ -f "$FILES/plugins/$VAR" ]; then
      if echo "$FILES/plugins/$VAR" | grep ".bz2$" &>/dev/null; then
        tar xjf "$FILES/plugins/$VAR" -C "$VDRCONFDIR/plugins/text2skin" && log "Extrahiere $VAR"
      else
        tar xzf "$FILES/plugins/$VAR" -C "$VDRCONFDIR/plugins/text2skin" && log "Extrahiere $VAR"
      fi
    else
      log "Installation von $VAR nicht erfolgreich"
    fi
  done

  # rechte setzen
  chown -R $VDRUSER:$VDRGROUP "$VDRCONFDIR/plugins/text2skin"
fi

exit 0


