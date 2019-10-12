REM Windows Image backup script
@echo off
:: BatchGotAdmin
::-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------
eventcreate /S \\%COMPUTERNAME% /L Application /T Success /SO "Backup event" /D "Backup is started" /ID 1
REM Backup destination drive
SET BACKUPDRIVE="J:"
REM !!DO NOT MODIFY!!
SET BACKUPPATH="\WindowsImageBackup"

rem RD /S /Q %BACKUPDRIVE%%BACKUPPATH%

IF %errorlevel%==0 eventcreate /S \\%COMPUTERNAME% /L Application /T Success /SO "Backup event" /D "Backup delete: %BACKUPDRIVE%%BACKUPPATH%" /ID 1
IF NOT %errorlevel%==0 eventcreate /S \\%COMPUTERNAME% /L Application /T Error /SO "Backup event" /D "Backup delete: %BACKUPDRIVE%%BACKUPPATH% is failed %ERRORLEVEL%" /ID 255

REM Use mountvol to list volumes
wbadmin start backup -backuptarget:%BACKUPDRIVE% -vssCopy -quiet -allCritical

IF %errorlevel%==0 eventcreate /S \\%COMPUTERNAME% /L Application /T Success /SO "Backup event" /D "Backup Finished" /ID 1
IF NOT %errorlevel%==0 eventcreate /S \\%COMPUTERNAME% /L Application /T Error /SO "Backup event" /D "Backup Failed: %ERRORLEVEL%" /ID 255
