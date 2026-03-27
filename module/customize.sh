#!/system/bin/sh

get_input() {
  timeout 1s /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME
}

ui_print " "
ui_print "  Select Cursor Theme:"
ui_print "   Vol+ = Light Cursor (White)"
ui_print "   Vol- = Dark Cursor (Black)"
ui_print " "

COUNT=0
SELECTED="none"
while [ $COUNT -lt 3600 ]; do
  EVENT=$(get_input)
  if echo "$EVENT" | grep -q "KEY_VOLUMEUP"; then
    SELECTED="light"
    break
  elif echo "$EVENT" | grep -q "KEY_VOLUMEDOWN"; then
    SELECTED="dark"
    break
  fi
  COUNT=$((COUNT + 1))
done

mkdir -p "$MODPATH/system/product/overlay"

if [ "$SELECTED" = "light" ]; then
  ui_print "- Selected: Light Theme"
  cp -f "$MODPATH/common/LightCursor.apk" "$MODPATH/system/product/overlay/CursorOverlay.apk"
else
  [ "$SELECTED" = "none" ] && ui_print "- Timeout: Defaulting to Dark Theme" || ui_print "- Selected: Dark Theme"
  cp -f "$MODPATH/common/DarkCursor.apk" "$MODPATH/system/product/overlay/CursorOverlay.apk"
fi
rm -rf "$MODPATH/common"

ui_print "- Installing Input Device Config..."
ui_print "- Injecting Resource Overlay..."
ui_print "- Installation Complete!"
ui_print " "
ui_print "  Go to Developer Options and"
ui_print "  ENABLE Show Taps to see the"
ui_print "  S-Pen hover pointer."
ui_print " "

set_perm_recursive "$MODPATH/system/usr/idc" 0 0 0755 0644
set_perm "$MODPATH/system/product/overlay/CursorOverlay.apk" 0 0 0644