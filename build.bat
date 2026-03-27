@echo off

set TOOLS=tools
set SRC=src
set OUT=out

if exist %OUT% rmdir /s /q %OUT%
mkdir %OUT%

:: ── Read version early ───────────────────────────────────────────
for /f "tokens=2 delims==" %%A in ('findstr "^version=" module\module.prop') do set VERSION=%%A
echo Version: %VERSION%

:: ── Build each variant ───────────────────────────────────────────
for %%V in (dark light) do (
    echo.
    echo [%%V - 1/4] Compiling...
    %TOOLS%\aapt2.exe compile --dir %SRC%\%%V\res -o %OUT%\compiled_%%V.flata
    if errorlevel 1 goto error

    echo [%%V - 2/4] Linking...
    %TOOLS%\aapt2.exe link ^
        --manifest %SRC%\%%V\AndroidManifest.xml ^
        -I %TOOLS%\framework-res.apk ^
        -o %OUT%\%%V_unaligned.apk ^
        %OUT%\compiled_%%V.flata
    if errorlevel 1 goto error
    del %OUT%\compiled_%%V.flata

    echo [%%V - 3/4] Zipaligning...
    %TOOLS%\zipalign.exe -p 4 %OUT%\%%V_unaligned.apk %OUT%\%%V_aligned.apk
    if errorlevel 1 goto error
    del %OUT%\%%V_unaligned.apk

    echo [%%V - 4/4] Signing...
    java -jar %TOOLS%\apksigner.jar sign ^
        --ks krugdev.jks ^
        --ks-key-alias spencursoroverlay ^
        --out %OUT%\%%V.apk ^
        %OUT%\%%V_aligned.apk
    if errorlevel 1 goto error
    del %OUT%\%%V_aligned.apk
    del %OUT%\%%V.apk.idsig 2>nul

    echo [%%V] Done.
)

:: ── Verify both APKs ─────────────────────────────────────────────
echo.
echo Verifying...
java -jar %TOOLS%\apksigner.jar verify -v %OUT%\dark.apk
java -jar %TOOLS%\apksigner.jar verify -v %OUT%\light.apk

:: ── Copy APKs into module/common ─────────────────────────────────
echo.
echo Copying APKs into module...
if not exist module\common mkdir module\common
copy /Y %OUT%\dark.apk  module\common\DarkCursor.apk
copy /Y %OUT%\light.apk module\common\LightCursor.apk
if errorlevel 1 goto error
del %OUT%\dark.apk
del %OUT%\light.apk

:: ── Package module zip ───────────────────────────────────────────
echo.
echo Packaging SPenCursorOverlay-%VERSION%.zip...
tools\7z.exe a -tzip -mx=9 "out\SPenCursorOverlay-%VERSION%.zip" ".\module\*"
if errorlevel 1 goto error

echo.
echo ================================================
echo  Build Complete!
echo  Module: out\SPenCursorOverlay-%VERSION%.zip
echo ================================================
goto end

:error
echo.
echo [ERROR] Build failed. See output above.
exit /b 1

:end