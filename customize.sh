ui_print ""
ui_print "- Select cursor style:"
ui_print "  Volume+  =  Dark cursor (white outline) [DEFAULT]"
ui_print "  Volume-  =  Light cursor (dark outline)"
ui_print ""

# Default to dark
cp "$MODPATH/variants/dark.apk" "$MODPATH/system/product/overlay/SPenCursor.apk"

# Wait for Volume- to switch, timeout after 10s
for i in $(seq 1 10); do
    getevent -lc 1 2>/dev/null | grep -q "KEY_VOLUMEDOWN" && {
        ui_print "- Selected: Light"
        cp "$MODPATH/variants/light.apk" "$MODPATH/system/product/overlay/SPenCursor.apk"
        break
    }
    getevent -lc 1 2>/dev/null | grep -q "KEY_VOLUMEUP" && {
        ui_print "- Selected: Dark (default)"
        break
    }
done

ui_print "- Cursor style set!"