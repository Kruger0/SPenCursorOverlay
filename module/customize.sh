#!/system/bin/sh

# --- Functions ---
# This function is a robust way to check for volume keys in Magisk
chooseport() {
  # This loop waits for a key press
  while true; do
    # -lqc 1 waits for exactly ONE event then stops
    # We use a short timeout so the script stays responsive
    VKSEL=$(timeout 1s /system/bin/getevent -lqc 1 2>/dev/null)
    
    case "$VKSEL" in
      *KEY_VOLUMEUP*) return 0 ;;
      *KEY_VOLUMEDOWN*) return 1 ;;
    esac
  done
}

ui_print " "
ui_print "  --- Select Cursor Color ---"
ui_print "  Vol+ = Light Theme"
ui_print "  Vol- = Dark Theme"
ui_print " "
ui_print "  Waiting 30s for input..."
ui_print "  (Defaults to Dark if no keys pressed)"
ui_print " "

# --- Selection Logic ---
# Run the listener in a subshell
timeout 30s sh -c '
  while true; do
    SEL=$(/system/bin/getevent -lqc 1)
    case "$SEL" in
      *KEY_VOLUMEUP*) exit 10 ;;
      *KEY_VOLUMEDOWN*) exit 11 ;;
    esac
  done
'
# Capture the exit code immediately after the subshell finishes
RET=$?

# Determine what happened based on the code
if [ $RET -eq 10 ]; then
  SELECTED="light"
elif [ $RET -eq 11 ]; then
  SELECTED="dark"
else
  # 124 is the standard exit code for 'timeout' command expiry
  SELECTED="none"
fi

# --- Apply Selection ---
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

if [ -f "$MODPATH/common/$FILE" ]; then
  cp -f "$MODPATH/common/$FILE" "$TARGET_DIR/CursorOverlay.apk"
else
  ui_print "! ERROR: Source $FILE not found in /common/"
fi

# Clean up module build files
rm -rf "$MODPATH/common"

ui_print "- Installing Input Device Config..."
sleep 0.2
ui_print "- Injecting Resource Overlay..."
sleep 0.2

# Set permissions
[ -d "$MODPATH/system/usr/idc" ] && set_perm_recursive "$MODPATH/system/usr/idc" 0 0 0755 0644
set_perm "$TARGET_DIR/CursorOverlay.apk" 0 0 0644

ui_print "- Installation Complete!"
sleep 0.5

ui_print " "
ui_print "  Go to Developer Options and"
ui_print "  ENABLE 'Show taps' to see the"
ui_print "  S-Pen hover pointer."
ui_print " "