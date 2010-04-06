#!/bin/sh
VDR_CONF="/etc/default/vdr"
source $VDR_CONF
ADMIN_CFG_FILE="$VDRCONFDIR/plugins/admin/admin.conf"

ORIG_IFS=$IFS  # save IFS

cat $ADMIN_CFG_FILE | while read new_line; do
  IFS=":"  # set IFS
  ARRAY=($new_line)
  GROUP=${ARRAY[0]}
  NAME=${ARRAY[1]}
  VAL=${ARRAY[2]}
  if [ "$(echo $GROUP | grep '^/')" ]; then
    NEW_VAL=$(echo $VAL | sed -e 's/;/:/g' -e 's/^ //g' -e 's/ $//g')
    VAR=$(grep -m 1 "^$NAME=" $VDR_CONF)
    OLD_VAL=$(echo $VAR | cut -f 2 -d '=')
    OLD_VAL=$(echo $OLD_VAL)
    if [ "$VAR" ] && [ "$OLD_VAL" != "$NEW_VAL" ]; then
      case $GROUP in
        /ARG)
          sed -i $VDR_CONF -e "s?$VAR?$NAME=\"$NEW_VAL\"?g"
        ;;
        /DIR)
          if [ ! -d "$NEW_VAL" ] && [ "$NAME" != "DVDBURNER" ]; then
            mkdir -p "$NEW_VAL"
            chown -R $VDRUSER.$VDRGROUP "$NEW_VAL"
          fi
          sed -i $VDR_CONF -e "s?$VAR?$NAME=\"$NEW_VAL\"?g"

          if [ "$NAME" = "DIVXDIR" ]; then
            PATH_EXISTS=$(grep "^$OLD_VAL;" "$VDRCONFDIR/plugins/mplayersources.conf")
            if [ "$PATH_EXISTS" ]; then
              sed -i "$VDRCONFDIR/plugins/mplayersources.conf" -e "s?$OLD_VAL?$NEW_VAL?g"
            else
              echo "$NEW_VAL;More Movies;0;*.avi" >> "$VDRCONFDIR/plugins/mplayersources.conf"
            fi
          fi

          if [ "$NAME" = "ISODIR" ]; then
            PATH_EXISTS=$(grep "^$OLD_VAL;" "$VDRCONFDIR/plugins/mplayersources.conf")
            if [ "$PATH_EXISTS" ]; then
              sed -i "$VDRCONFDIR/plugins/mplayersources.conf" -e "s?$OLD_VAL?$NEW_VAL?g"
            else
              echo "$NEW_VAL;More DVDs;0;*.iso" >> "$VDRCONFDIR/plugins/mplayersources.conf"
            fi
          fi

          if [ "$NAME" = "MUSICDIR" ]; then
            PATH_EXISTS=$(grep "^$OLD_VAL;" "$VDRCONFDIR/plugins/mp3ng/mp3sources.conf")
            if [ "$PATH_EXISTS" ]; then
              sed -i "$VDRCONFDIR/plugins/mp3ng/mp3sources.conf" -e "s?$OLD_VAL?$NEW_VAL?g"
            else
              echo "$NEW_VAL;More Music;0;*.mp3/*.ogg/*.wav" >> "$VDRCONFDIR/plugins/mp3ng/mp3sources.conf"
            fi
            PATH_EXISTS=$(grep "^$OLD_VAL;" "$VDRCONFDIR/plugins/mp3sources.conf")
            if [ "$PATH_EXISTS" ]; then
              sed -i "$VDRCONFDIR/plugins/mp3sources.conf" -e "s?$OLD_VAL?$NEW_VAL?g"
            else
              echo "$NEW_VAL;More Music;0;*.mp3/*.ogg/*.wav" >> "$VDRCONFDIR/plugins/mp3sources.conf"
            fi
          fi

          if [ "$NAME" = "PICTUREDIR" ]; then
            PATH_EXISTS=$(grep "^$OLD_VAL;" "$VDRCONFDIR/plugins/imagesources.conf")
            if [ "$PATH_EXISTS" ]; then
              sed -i "$VDRCONFDIR/plugins/imagesources.conf" -e "s?$OLD_VAL?$NEW_VAL?g"
            else
              echo "$NEW_VAL;More Pictures;0;*.jpg *.JPG"  >> "$VDRCONFDIR/plugins/imagesources.conf"
            fi
          fi

          if [ "$NAME" = "VIDEODIR" ]; then
            PATH_EXISTS=$(grep "^$OLD_VAL;" "$VDRCONFDIR/plugins/mplayersources.conf")
            if [ "$PATH_EXISTS" ]; then
              sed -i "$VDRCONFDIR/plugins/mplayersources.conf" -e "s?$OLD_VAL?$NEW_VAL?g"
            else
              echo "$NEW_VAL;More Recordings;0;*0*.vdr" >> "$VDRCONFDIR/plugins/mplayersources.conf"
            fi
          fi
        ;;
        /PLG)
          PLUGIN_NAME="$NAME"
          [ "$NAME" = "streamdev_client" ] && PLUGIN_NAME="streamdev-client"
          [ "$NAME" = "streamdev_server" ] && PLUGIN_NAME="streamdev-server"
          if [ "$NEW_VAL" = "1" ] && [ -f $VDRLIBDIR/libvdr-$PLUGIN_NAME.so* ]; then
            sed -i $VDR_CONF -e "s/$VAR/$NAME=\"on\"/g"
          else
            sed -i $VDR_CONF -e "s/$VAR/$NAME=\"off\"/g"
          fi
        ;;
        /VAR)
          if [ "$NEW_VAL" = "1" ]; then
            sed -i $VDR_CONF -e "s/$VAR/$NAME=\"on\"/g"
          else
            sed -i $VDR_CONF -e "s/$VAR/$NAME=\"off\"/g"
          fi
        ;;
        /*)
          sed -i $VDR_CONF -e "s/$VAR/$NAME=\"$NEW_VAL\"/g"
        ;;
      esac
    fi
  fi
done

IFS=$ORIG_IFS  # reset IFS

exit 0
