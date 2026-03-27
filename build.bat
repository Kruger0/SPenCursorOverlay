@echo off
setlocal enabledelayedexpansion

set TOOLS=tools
set SRC=src
set MODULE=module
set OUT=out

:: ── Clean output folder ──────────────────────────────────────────
if exist %OUT% rmdir /s /q %OUT%
mkdir %OUT%
mkdir %OUT%\apks

:: ── Build each variant ───────────────────────────────────────────
for %%V in (dark light auto) do (
    echo.
    echo [%%V] Compiling...
    %TOOLS%\aapt2 compile --dir %SRC%\%%V\res -o %OUT%\compiled_%%V.flata
    if errorlevel 1 goto error

    echo [%%V] Linking...
    %TOOLS%\aapt2 link ^
        --manifest %SRC%\%%V\AndroidManifest.xml ^
        -I %TOOLS%\framework-res.apk ^
        -o %OUT%\%%V_unaligned.apk ^
        %OUT%\compiled_%%V.flata
    if errorlevel 1 goto error
    del %OUT%\compiled_%%V.flata

    echo [%%V] Zipaligning...
    %TOOLS%\zipalign.exe -p 4 %OUT%\%%V_unaligned.apk %OUT%\%%V_aligned.apk
    if errorlevel 1 goto error
    del %OUT%\%%V_unaligned.apk

    echo [%%V] Signing...
    java -jar %TOOLS%\apksigner.jar sign ^
        --ks %TOOLS%\debug.keystore ^
        --ks-pass pass:android ^
        --out %OUT%\apks\SPenCursorOverlay-%%V.apk ^
        %OUT%\%%V_aligned.apk
    if errorlevel 1 goto error
    del %OUT%\%%V_aligned.apk
    del %OUT%\apks\SPenCursorOverlay-%%V.apk.idsig 2>nul

    echo [%%V] OK
)

:: ── Copy APKs into module tree ───────────────────────────────────
echo.
echo Copying APKs into module...
copy /Y %OUT%\apks\SPenCursorOverlay-dark.apk  %MODULE%\system\product\overlay\SPenCursorOverlay-Dark.apk
copy /Y %OUT%\apks\SPenCursorOverlay-light.apk %MODULE%\system\product\overlay\SPenCursorOverlay-Light.apk
copy /Y %OUT%\apks\SPenCursorOverlay-auto.apk  %MODULE%\system\product\overlay\SPenCursorOverlay-Auto.apk

:: ── Read version from module.prop ────────────────────────────────
for /f "tokens=2 delims==" %%A in ('findstr "^version=" %MODULE%\module.prop') do set VERSION=%%A
set ZIPNAME=SPenCursorOverlay-%VERSION%.zip

:: ── Package module zip ───────────────────────────────────────────
echo.
echo Packaging %ZIPNAME%...
powershell -NoProfile -Command ^
    "Compress-Archive -Path '%MODULE%\*' -DestinationPath '%OUT%\%ZIPNAME%' -Force"
if errorlevel 1 goto error

:: ── Done ─────────────────────────────────────────────────────────
echo.
echo ================================================
echo  Build complete^^!
echo  APKs : out\apks\SPenCursorOverlay-[dark/light/auto].apk
echo  Module: out\%ZIPNAME%
echo ================================================
goto end

:error
echo.
echo [ERROR] Build failed at step above.
exit /b 1

:end