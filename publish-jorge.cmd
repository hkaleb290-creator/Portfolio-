@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SOURCE_DIR=%~dp0portfolio-starter-template"
set "TARGET_REPO=https://github.com/hkaleb290-creator/Jorge-portfolio-.git"
set "WORK_DIR=%TEMP%\jorge-portfolio-publish-%RANDOM%%RANDOM%"
set "LIVE_URL=https://hkaleb290-creator.github.io/Jorge-portfolio-/"

if /I "%~1"=="--help" goto :help
if /I "%~1"=="-h" goto :help

set "COMMIT_MSG=%*"
if not defined COMMIT_MSG set "COMMIT_MSG=Update Jorge portfolio"

where git >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Git is not installed or not on PATH.
  exit /b 1
)

if not exist "%SOURCE_DIR%\index.html" (
  echo [ERROR] Source file not found: %SOURCE_DIR%\index.html
  exit /b 1
)

echo [1/5] Preparing temp publish folder...


echo [2/5] Cloning target repository...
git clone "%TARGET_REPO%" "%WORK_DIR%"
if errorlevel 1 (
  echo [ERROR] Could not clone target repository.
  exit /b 1
)

echo [3/5] Copying site files...
robocopy "%SOURCE_DIR%" "%WORK_DIR%" /E /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 (
  echo [ERROR] File copy failed.
  exit /b 1
)

pushd "%WORK_DIR%"

echo [4/5] Creating commit if needed...
git add .
git diff --cached --quiet
if not errorlevel 1 goto :hasChanges

echo [INFO] No changes detected. Nothing to publish.
popd
goto :success

:hasChanges
for /f "delims=" %%I in ('git -C "%~dp0" log -1 --pretty^=format:"%%an" 2^>nul') do set "GIT_NAME=%%I"
for /f "delims=" %%I in ('git -C "%~dp0" log -1 --pretty^=format:"%%ae" 2^>nul') do set "GIT_EMAIL=%%I"

if not defined GIT_NAME set "GIT_NAME=Kaleb Harris"
if not defined GIT_EMAIL set "GIT_EMAIL=hkaleb290@gmail.com"

git config user.name "%GIT_NAME%"
git config user.email "%GIT_EMAIL%"
git branch -M main
git commit -m "%COMMIT_MSG%"
if errorlevel 1 (
  echo [ERROR] Commit failed.
  popd
  exit /b 1
)

echo [5/5] Pushing to GitHub...
git push -u origin main
if errorlevel 1 (
  echo [ERROR] Push failed.
  popd
  exit /b 1
)

popd

:success
echo [DONE] Publish complete.
echo [DONE] Live site: %LIVE_URL%
exit /b 0

:help
echo.
echo Usage:
echo   publish-jorge.cmd [commit message]
echo.
echo Examples:
echo   publish-jorge.cmd
echo   publish-jorge.cmd Update experience section and links
echo.
exit /b 0
