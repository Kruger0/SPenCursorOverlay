@echo off

:: ── Refresh PATH so gh is available ──────────────────────────────
set "PATH=%PATH%;%LOCALAPPDATA%\Programs\GitHub CLI\;C:\Program Files\GitHub CLI\"

:: ── Read current version from module.prop ────────────────────────
for /f "tokens=2 delims==" %%A in ('findstr "^version=" module\module.prop') do set VERSION=%%A
for /f "tokens=2 delims==" %%A in ('findstr "^versionCode=" module\module.prop') do set VERSIONCODE=%%A

echo.
echo Current version : %VERSION% (code %VERSIONCODE%)
echo.
set /p NEWVERSION="New version: "
set /p NEWCODE="New version code: "

:: ── Bump module.prop ─────────────────────────────────────────────
powershell -NoProfile -Command "$content = Get-Content 'module\module.prop'; $content = $content -replace '^version=.*', 'version=%NEWVERSION%'; $content = $content -replace '^versionCode=.*', 'versionCode=%NEWCODE%'; $content | Set-Content 'module\module.prop'"
if errorlevel 1 goto error

:: ── Update update.json ───────────────────────────────────────────
powershell -NoProfile -Command "$json = '{\"version\": \"%NEWVERSION%\", \"versionCode\": %NEWCODE%, \"zipUrl\": \"https://github.com/Kruger0/SPenCursorOverlay/releases/download/%NEWVERSION%/SPenCursorOverlay-%NEWVERSION%.zip\", \"changelog\": \"https://raw.githubusercontent.com/Kruger0/SPenCursorOverlay/main/CHANGELOG.md\"}'; $json | Set-Content 'update.json'"
if errorlevel 1 goto error

:: ── Build ────────────────────────────────────────────────────────
echo.
echo Building...
call build.bat
if errorlevel 1 goto error

:: ── Pull remote changes before committing ────────────────────────
echo.
echo Syncing with remote...
git stash
git pull origin main --rebase
git stash pop
if errorlevel 1 goto error

:: ── Commit and tag ───────────────────────────────────────────────
echo.
echo Committing...
git add module\module.prop update.json
git commit -m "chore: release %NEWVERSION%"
if errorlevel 1 goto error

git tag %NEWVERSION%
git push origin main
git push origin %NEWVERSION%
if errorlevel 1 goto error

:: ── Create GitHub release with auto-generated notes ──────────────
echo.
echo Creating GitHub release %VERSION%...
gh release create %VERSION% ^
    "out\SPenCursorOverlay-%VERSION%.zip" ^
    --title "%VERSION%" ^
    --generate-notes
if errorlevel 1 goto error

echo.
echo ================================================
echo  Released %NEWVERSION% successfully!
echo  https://github.com/Kruger0/SPenCursorOverlay/releases/tag/%NEWVERSION%
echo ================================================
goto end

:error
echo.
echo [ERROR] Something failed. See output above.
exit /b 1

:end