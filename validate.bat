@echo off
setlocal
set appName=validate
set appDesc=Validate a source folder
set appVersion=1.0.1
set appAuthor=Filip Kriz
title Started: %appName%

echo.
echo ********************************
echo *   %appName%
echo *   %appDesc%
echo *   Version :   %appVersion%
echo *   Author  :   %appAuthor%
echo ********************************
echo.

IF [%1]==[?]  goto:help
IF [%1]==[]   goto:help
IF NOT [%1]==[] set srcDir=%1
IF NOT [%2]==[] set level=%2
IF [%2]==[]   goto:help
IF NOT [%3]==[] set phase=%3
IF [%3]==[]   goto:help
IF [%4]==[]     set verbosity=2
IF NOT [%4]==[] set verbosity=%4
IF [%5]==[] set mode=prod
IF NOT [%5]==[] set mode=test

set runDir=%CD%
set batchDir=%CD%\_batch
set logDir=%CD%\_report
set resDir=%CD%\resources
set tempDir=%CD%\_temp

set validator=%runDir%\KomplexniValidatorCLI-2.3.1.jar

set val_commons_psp=--verbosity %verbosity% --action VALIDATE_PSP --config-dir %runDir%\validatorConfig --psp 

if %phase%==all (
set val_disabled=--disable-mp3val --disable-shntool --disable-checkmate 
)
if %phase%==base (
set val_disabled=--disable-mp3val --disable-shntool --disable-checkmate --disable-imagemagick --disable-jhove --disable-jpylyzer --disable-kakadu
)

set val_tools=--jhove-path %resDir%\jhove --jpylyzer-path %resDir%\jpylyzer --imagemagick-path %resDir%\im --kakadu-path %resDir%\kakadu

FOR /F "usebackq tokens=1,2,3,4 delims=. " %%i IN (`date /t`) DO (
set datProc=%%k%%j%%i
)
set log=%logDir%\%datProc%_%appName%_log.txt

echo. >> %log%
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
echo PSP level :  %level%
echo PSP level :  %level% >> %log%
echo Running mode :  %mode%
echo Running mode :  %mode% >> %log%
echo Date of proc :  %datProc% >> %log%
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
if not %badFolderNames%==0 goto:finished

echo.
java -jar %validator% --version
echo.
echo Processing...
echo.

setlocal enabledelayedexpansion

for /f "tokens=*" %%A in ('dir /b /ad') do (
echo. >> %log%
echo %%A

if %level%==1 (

set /a totalFolders += 1
set base_dir=%srcDir%\%%A
set base_rep=%logDir%\%%A

echo %%A >> %log%
call:validate !base_dir! !base_rep! %mode%
)

if %level%==2 (
for /f "tokens=*" %%B in ('dir %%A /b /ad') do (

set /a totalFolders += 1
set base_dir=%srcDir%\%%A\%%B
set base_rep=%logDir%\%%A_%%B

echo %%A	%%B >> %log%
call:validate !base_dir! !base_rep! %mode%
)
) 

if %level%==3 (
for /f "tokens=*" %%B in ('dir %%A /b /ad') do (
for /f "tokens=*" %%C in ('dir %%A\%%B /b /ad') do (

set /a totalFolders += 1
set base_dir=%srcDir%\%%A\%%B\%%C
set base_rep=%logDir%\%%A_%%B_%%C

echo %%A	%%B	%%C >> %log%
call:validate !base_dir! !base_rep! %mode%
)
)
)

)

setlocal disabledelayedexpansion

:finished
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
echo    %appName% sourceFolder pspLevel phase [verbosity] [mode]
echo  Params:
echo    1 :  Source folder full path
echo    2 :  Steps to reach a PSP subfolder:  1-3
echo    3 :  Validating phase:  base  all - default: base
echo    4 :  [optional] Verbosity:  1-3  - default: 2
echo    5 :  [optional] Running mode: test - default: prod
echo.
echo  Examples:
echo    %appName% C:\some\data 1 base
echo    %appName% C:\some\data 2 all 3
echo    %appName% C:\some\data 2 base 1 test
echo.
goto:eof


:validate
if %3==test (
echo java -jar %validator% %val_commons_psp% "%1" --xml-protocol-file "%2_protocol.xml" --tmp-dir %tempDir% %val_tools% %val_disabled% > %2_report.txt 2>&1
)
if %3==prod (
java -jar %validator% %val_commons_psp% "%1" --xml-protocol-file "%2_protocol.xml" --tmp-dir %tempDir% %val_tools% %val_disabled% > %2_report.txt 2>&1
)
