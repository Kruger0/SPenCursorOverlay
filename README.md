S-Pen Cursor & Pointer Fix
This Magisk module is designed for Samsung Galaxy Tab devices running AOSP-based ROMs (LineageOS, Derpfest, etc.). It resolves the visibility issues caused by flagging the S-Pen as a mouse input while restoring the signature OneUI aesthetic.

🚀 Features
Input Restoration: Reverts the S-Pen flag from "Mouse" back to "Touchscreen" for better native behavior.

Classic Pointer: Restores the standard pointer_arrow vector, making external OTG/Bluetooth mice usable again.

OneUI Aesthetics: Replaces the generic hover spot with the official OneUI S-Pen hover icon.

Clean Touch Experience: Makes the "Show Taps" indicator invisible for finger touches, ensuring the S-Pen spot is the only thing you see.

🛠 Prerequisites
Magisk installed.

"Show Taps" must be enabled in Developer Options for the S-Pen spot to be visible.

📦 Installation
Download the latest ZIP from the Releases page.

Install via Magisk app.

(Optional) Choose between Light or Dark pointer themes during installation (WIP).

Reboot your device.

📝 Note on "Show Taps"
By using this module, your finger touches will be invisible even with "Show Taps" on. The S-Pen pointer will disappear when the nib touches the screen, mimicking the behavior of original Samsung firmware.


# SPenCursorOverlay

**A Magisk module for Galaxy Tab devices running AOSP-based ROMs (LineageOS, DerpFest).**  
Restores a proper arrow pointer for OTG/Bluetooth mouse use, while keeping the OneUI S Pen hover dot as the tap indicator — without polluting every finger touch with a visible spot.

> Requires **"Show taps"** to be enabled in Developer Options.

---

## Background

When running a stock OneUI ROM, Galaxy Tab's S Pen is recognized as a dedicated stylus input. On AOSP-based custom ROMs like LineageOS and DerpFest, that layer is gone — the S Pen falls back to being detected as a plain touchscreen device, making it completely invisible on screen.

To fix this, LineageOS and DerpFest developers flag the S Pen as a **mouse input device** and replace the default `pointer_arrow` with a small, hollow OneUI-style dot. This works well if you only use the S Pen — but the moment you plug in an OTG or Bluetooth mouse, you're stuck navigating with a tiny, nearly invisible dot instead of a proper arrow cursor.

---

## What This Module Does

| Change | Effect |
|--------|--------|
| Reverts S Pen input flag | S Pen is recognized as touchscreen again (invisible unless "Show taps" is on) |
| Restores `pointer_arrow` | OTG/Bluetooth mouse shows a standard arrow cursor |
| Replaces `pointer_spot_hover` | S Pen hover/tap shows the OneUI-style dot (requires "Show taps") |
| Makes `pointer_spot_touch` invisible | Finger touches don't show a dot even with "Show taps" enabled |

**Trade-off:** When the S Pen tip physically touches the screen, the dot disappears — but since the tip is already on the screen, you always know where it is. The hover indicator still appears before contact.

---

## Requirements

- Android device: **Samsung Galaxy Tab** with S Pen support
- Custom ROM: **LineageOS**, **DerpFest**, or another AOSP-based ROM that applies the S Pen mouse flag patch
- Root: **Magisk** (v20.4+) or **KernelSU**
- Developer Options → **Show taps**: must be **enabled**

---

## Installation

1. Download the latest `.zip` from [Releases](../../releases)
2. Open **Magisk** → Modules → Install from storage
3. Select the downloaded zip
4. During installation, choose your pointer theme:
   - `1` — **Dark** pointer (white arrow on dark outline)
   - `2` — **Light** pointer (dark arrow on light outline)
   - `3` — **Auto** *(WIP — follows system dark/light mode via RRO)*
5. Reboot

---

## Options

### Pointer Theme (chosen at install time)
The installer prompts you to pick a cursor style suited to your wallpaper/preference. To change it later, reinstall the module and select a different option.

> **Auto mode** is planned pending confirmation that RRO overlays can detect the system night mode at install time. Contributions welcome.

---

## Known Limitations

- **"Show taps" must be on.** The S Pen hover dot relies on the tap indicator system; there is currently no way to show the S Pen dot without enabling it globally.
- **S Pen contact hides the dot.** When the S Pen tip touches the screen, `pointer_spot_touch` is intentionally transparent, so no indicator appears at the contact point. This is by design.
- **Finger touches are invisible.** As a side effect of making `pointer_spot_touch` transparent, finger tap indicators are also hidden even with "Show taps" on. This is the intended behavior.
- **ROM-specific.** This module targets ROMs that already apply the S Pen-as-mouse patch (LineageOS, DerpFest). It may have no effect or behave unexpectedly on stock OneUI.

---

## Compatibility

| ROM | Status |
|-----|--------|
| LineageOS 21 (Android 14) | ✅ Tested |
| DerpFest | ✅ Tested |
| Other AOSP ROMs with S Pen patch | ⚠️ Likely works, untested |
| Stock OneUI | ❌ Not supported |

Tested on: *[add your device model here, e.g. Samsung Galaxy Tab S6 Lite]*

---

## Credits

- **LineageOS & DerpFest contributors** — for the original S Pen mouse flag patch and OneUI dot design that this module builds on
- Inspired by the pointer customization work in AOSP `frameworks/base`

---

## License

[GPL-3.0](LICENSE)