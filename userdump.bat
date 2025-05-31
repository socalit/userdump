@echo off
cls

echo.
echo ============================================================
echo =     userdump - SYSTEM BACKUP TOOL - @SoCal_IT            =
echo ============================================================
echo =   User: %USERNAME%
echo =   PC Name: %COMPUTERNAME%
echo ------------------------------------------------------------
echo =   [ ] Copying profile data...
echo =   [ ] Compatible with Windows XP to 11
echo =   [ ] Stay Backed Up with SoCal_IT
echo ============================================================
echo.

pause
cls

echo.
echo Where do you want to save the backup?
echo ------------------------------------------------------------
echo You can enter the path to:
echo.
echo   - A USB drive (e.g. E:\ or F:\)
echo     . Plug in your USB flash or external hard drive first
echo     . Look in "This PC" to find the drive letter
echo.
echo   - A network folder (e.g. \\Server\Share)
echo     . Make sure the network share is reachable
echo     . Use double backslashes (\\) before the server name
echo     . Example: \\192.168.1.10\Backups or \\OfficeNAS\UserData
echo ------------------------------------------------------------

set "destination_dir="
set /p "destination_dir=Enter backup destination path: "

if not exist "%destination_dir%" (
    echo ERROR: Destination not found or unavailable.
    goto ask_destination
)

echo test > "%destination_dir%\~test.txt"
if not exist "%destination_dir%\~test.txt" (
    echo ERROR: Cannot write to destination. Check permissions or network connection.
    goto ask_destination
)
del "%destination_dir%\~test.txt"

set "userprofile_dir=%USERPROFILE%"
set "username=%USERNAME%"
set "computername=%COMPUTERNAME%"
set "backup_path=%destination_dir%\User_files_backup\%username%\%computername%"
set "backupcmd=xcopy /s /c /d /e /i /r /y"

echo.
echo --------------- Starting Full Backup of User Profile ------------------

%backupcmd% "%userprofile_dir%" "%backup_path%"

%backupcmd% "%userprofile_dir%\Local Settings\Application Data\Microsoft" "%backup_path%\AppData\Local\Microsoft" 2>nul
%backupcmd% "%userprofile_dir%\Local Settings\Application Data\Programs" "%backup_path%\AppData\Local\Programs" 2>nul
%backupcmd% "%userprofile_dir%\Application Data" "%backup_path%\AppData\Roaming" 2>nul

echo.
echo --------------- Backup Complete ----------------------------------------
echo Files saved to: %backup_path%
echo.

pushd "%backup_path%" >nul
for /f "tokens=3,5" %%a in ('dir /s ^| findstr "File(s)"') do (
    set "total_files=%%a"
    set "total_bytes=%%b"
)
popd

setlocal enabledelayedexpansion
set "bytes=!total_bytes:,=!"
set /a size_gb=!bytes! / 1073741824
set /a size_rem=!bytes! %% 1073741824
set /a size_mb=(size_rem + 524288) / 1048576

echo --------------- Summary -----------------------------------------------
echo Total Files Backed Up : %total_files%
echo Total Size            : !size_gb!.!size_mb! GB
endlocal

pause