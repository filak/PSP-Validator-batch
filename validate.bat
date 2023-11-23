@echo off
setlocal
set appName=validate
set appDesc=Validate a source folder
set appVersion=1.0
set appAuthor=Filip Kriz
title Started: %appName%

echo.
echo ******************************************************
echo *   %appName%
echo *   %appDesc%
echo *   Version :   %appVersion%
echo *   Author  :   %appAuthor%
echo ******************************************************
echo.

IF [%1]==[?]  goto:help
IF [%1]==[]   goto:help
IF NOT [%1]==[] set srcDir=%1
IF [%2]==[]     set verbosity=2
IF NOT [%2]==[] set verbosity=%2

set runDir=%CD%
set batchDir=%CD%\_batch
set logDir=%CD%\_report
set resDir=%CD%\resources
set tempDir=%CD%\_temp

set validator=%runDir%\KomplexniValidatorCLI-2.3.jar

set val_commons_psp=--verbosity %verbosity% --action VALIDATE_PSP --config-dir %runDir%\validatorConfig --psp 
set val_disabled=--disable-mp3val --disable-shntool --disable-checkmate
rem  --disable-jhove --disable-jpylyzer --disable-kakadu
set val_tools=--jhove-path %resDir%\jhove --jpylyzer-path %resDir%\jpylyzer --imagemagick-path %resDir%\im --kakadu-path %resDir%\kakadu

FOR /F "usebackq tokens=1,2,3,4 delims=. " %%i IN (`date /t`) DO (
set datProc=%%l%%k%%j
)
set log=%logDir%\%datProc%_%appName%_log.txt

echo. > %log%
echo *** Started ***
echo Started  :   %date%  %time%
echo Started  :   %date%  %time% >> %log%
echo.
echo. >> %log%

set /a totalFolders = 0
set /a badFolderNames = 0
set /a errors = 0

set folderList=%batchDir%\S_Folders.txt
set badNames=%batchDir%\S_BadPath.txt

echo. 2>%badNames%

echo Source folder :  %srcDir%
echo Source folder :  %srcDir% >> %log%
echo Date of proc  :  %datProc% >> %log%
echo.
echo. >> %log%
echo FolderList:   %folderList%
echo FolderList:   %folderList% >> %log%
echo.
echo. >> %log%

cd /D %srcDir%

dir /ad /b /s > %folderList%

for /f %%D in (%folderList%) do (

IF NOT EXIST %%D (
set /a badFolderNames += 1
echo FOLDER:  %%D >> %badNames%
)
)

echo.
java -jar %validator% --version
echo.
echo Processing...
echo.

SETLOCAL ENABLEDELAYEDEXPANSION
for /f "tokens=*" %%A in ('dir /b /ad') do (
echo. >> %log%
echo %%A
for /f "tokens=*" %%B in ('dir %%A /b /ad') do (

for /f "tokens=*" %%C in ('dir %%A\%%B /b /ad') do (

set /a totalFolders += 1
set protocol=%logDir%\%%A_%%B_%%C_protocol.xml
set report=%logDir%\%%A_%%B_%%C_report.txt

echo %%A	%%B	%%C >> %log%

rem echo java -jar %validator% %val_commons_psp% "%srcDir%\%%A\%%B\%%C" --xml-protocol-file "!protocol!" --tmp-dir %tempDir% %val_tools% %val_disabled% > !report! 2>&1 
java -jar %validator% %val_commons_psp% "%srcDir%\%%A\%%B\%%C" --xml-protocol-file "!protocol!" --tmp-dir %tempDir% %val_tools% %val_disabled% > !report! 2>&1

)
)
)

echo.
echo Done!
echo.

cd /D %runDir%
echo.
echo. >> %log%
echo *** Finished ***
echo Finished :   %date%  %time%
echo Finished :   %date%  %time% >> %log%
echo.
echo Report   :   %log%
echo Report   :   %log% >> %log%
echo.
echo Processed:   %totalFolders%  Folders
echo Processed:   %totalFolders%  Folders >> %log%
echo.
echo Bad folder names :   %badFolderNames%
echo Bad folder names :   %badFolderNames% >> %log%
echo.
echo. >> %log%
set /a errors=badFolderNames
if not %errors%==0 (
echo Errors occured - check %badNames%
echo - repair folder names first
echo   and run this script again !
echo.
)

title Finished! %appName%
goto:eof


:help
echo *** Help ***
echo  Usage:
echo    %appName% sourceFolder [verbosity]
echo  Params:
echo    1 :  Source folder full path
echo    2 :  [optional] Verbosity 1-3 / default: 2
echo.
echo  Examples:
echo    %appName% C:\some\data
echo    %appName% C:\some\data 3
echo.
goto:eof

endlocal
