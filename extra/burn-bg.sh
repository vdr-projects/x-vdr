#!/bin/sh

# CONFIG BEGIN
  . /etc/default/vdr
  TEMPLATEURL=http://vdr.f-x.de
  TEMPLATEDIR=$VDRCONFDIR/plugins/burn
  TEXT="Vorlage (burn)"
# CONFIG END

cp $TEMPLATEDIR/menu-bg.png $TEMPLATEDIR/original.png

wget \
        --mirror --no-directories --accept="zip" "$TEMPLATEURL" --directory-prefix="$TEMPLATEDIR/tmp"

find "$TEMPLATEDIR" \
        -name "*.zip" -exec unzip -o -q -d "$TEMPLATEDIR" \{} \;

find "$TEMPLATEDIR" \( ! -name 'menu-b*.png' \) \
        -name "*.png" -printf "\n$TEXT %f : cp -v \"$TEMPLATEDIR/%f\" \"$TEMPLATEDIR/menu-bg.png\";" \
        > "$TEMPLATEDIR/reccmds.conf" 

chown $VDRUSER.$VDRGROUP -R $VDRCONFDIR/plugins/burn
