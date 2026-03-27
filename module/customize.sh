#!/system/bin/sh

# ─── UI Header ──────────────────────────────────────────────────
ui_print " "
ui_print "  --- Select Cursor Color ---"
ui_print "  Vol+ = Light Theme"
ui_print "  Vol- = Dark Theme"
ui_print " "
ui_print "  Waiting 30s for input..."
ui_print "  (Defaults to Dark if no keys pressed)"
ui_print " "

# ─── Background Key Listener ────────────────────────────────────
rm -f /tmp/key_event
(/system/bin/getevent -lqc 10 > /tmp/key_event) &
GETEVENT_PID=$!

COUNT=30
SELECTED="none"

# ─── Selection Loop ─────────────────────────────────────────────
while [ $COUNT -gt 0 ]; do
  if grep -q "KEY_VOLUMEUP" /tmp/key_event 2>/dev/null; then
    SELECTED="light"
    break
  elif grep -q "KEY_VOLUMEDOWN" /tmp/key_event 2>/dev/null; then
    SELECTED="dark"
    break
  fi
  sleep 1
  COUNT=$((COUNT - 1))
done

# Clean up the background process and temp file
kill $GETEVENT_PID 2>/dev/null
rm -f /tmp/key_event

# ─── Handle Selection ───────────────────────────────────────────
TARGET_DIR="$MODPATH/system/product/overlay"
mkdir -p "$TARGET_DIR"

if [ "$SELECTED" = "light" ]; then
  FILE="LightCursor.apk"
  ui_print "- Selected: Light Theme"
else
  FILE="DarkCursor.apk"
  if [ "$SELECTED" = "none" ]; then
    ui_print "- Timeout: Defaulting to Dark Theme"
  else
    ui_print "- Selected: Dark Theme"
  fi
fi
sleep 1.0

# ─── Installation Logic ─────────────────────────────────────────
if [ -f "$MODPATH/common/$FILE" ]; then
  cp -f "$MODPATH/common/$FILE" "$TARGET_DIR/CursorOverlay.apk"
else
  ui_print "! ERROR: Source $FILE not found in /common/"
fi

rm -rf "$MODPATH/common"

ui_print "- Installing Input Device Config..."
sleep 0.2
ui_print "- Injecting Resource Overlay..."
sleep 0.2

[ -d "$MODPATH/system/usr/idc" ] && set_perm_recursive "$MODPATH/system/usr/idc" 0 0 0755 0644
set_perm "$TARGET_DIR/CursorOverlay.apk" 0 0 0644

ui_print "- Installation Complete!"
sleep 0.5

# ─── Instructions ───────────────────────────────────────────────
ui_print " "
ui_print "  Go to Developer Options and"
ui_print "  ENABLE 'Show taps' to see the"
ui_print "  S-Pen hover pointer."
ui_print " "