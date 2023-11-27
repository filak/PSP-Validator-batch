@echo off
setlocal
set appName=validate
set appDesc=Validate NDK PSPs
set appVersion=1.1.2 2023-11-27
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
IF [%2]==[]   goto:help
IF NOT [%2]==[] set level=%2
IF [%3]==[]   goto:help
IF NOT [%3]==[] set mode=%3
IF [%4]==[]   goto:help
IF NOT [%4]==[] set tools=%4
IF [%5]==[]     set verbosity=2
IF NOT [%5]==[] set verbosity=%5

set runDir=%CD%
set batchDir=%CD%\_batch
set logDir=%CD%\_logs
set repDir=%CD%\_reports
set resDir=%CD%\resources
set tempDir=%CD%\_temp

set validator=%runDir%\KomplexniValidatorCLI-2.3.1.jar
set jpyl=jpylyzer\1.18.0

set val_psp=--verbosity %verbosity% --action VALIDATE_PSP --config-dir %runDir%\validatorConfig --psp
set val_group=--verbosity %verbosity% --action VALIDATE_PSP_GROUP --config-dir %runDir%\validatorConfig --psp-group 

set disabled_audio=--disable-mp3val --disable-shntool --disable-checkmate
set val_tools=--jhove-path %resDir%\jhove --jpylyzer-path %resDir%\%jpyl% --imagemagick-path %resDir%\im --kakadu-path %resDir%\kakadu

if %tools%==none (
set val_disabled=%disabled_audio% --disable-imagemagick --disable-jhove --disable-jpylyzer --disable-kakadu
)
if %tools%==im (
set val_disabled=%disabled_audio% --disable-jhove --disable-jpylyzer --disable-kakadu
rem set val_tools=--imagemagick-path %resDir%\im
)
if %tools%==jhove (
set val_disabled=%disabled_audio% --disable-imagemagick --disable-jpylyzer --disable-kakadu
rem set val_tools=--jhove-path %resDir%\jhove
)
if %tools%==jpyl (
set val_disabled=%disabled_audio% --disable-imagemagick --disable-jhove --disable-kakadu
rem set val_tools=--jpylyzer-path %resDir%\%jpyl%
)
if %tools%==kdu (
set val_disabled=%disabled_audio% --disable-imagemagick --disable-jhove --disable-jpylyzer
rem set val_tools=--kakadu-path %resDir%\kakadu
) 
if %tools%==jhove_jpyl (
rem set val_disabled=%disabled_audio%
set val_disabled=%disabled_audio% --disable-imagemagick --disable-kakadu
rem set val_tools=--jhove-path %resDir%\jhove --jpylyzer-path %resDir%\%jpyl% --imagemagick-path %resDir%\im --kakadu-path %resDir%\kakadu
)
if %tools%==images (
set val_disabled=%disabled_audio%
rem set val_tools=--jhove-path %resDir%\jhove --jpylyzer-path %resDir%\%jpyl% --imagemagick-path %resDir%\im --kakadu-path %resDir%\kakadu
)

FOR /F "usebackq tokens=1,2,3,4 delims=. " %%i IN (`date /t`) DO (
set datProc=%%k%%j%%i
)
set log=%logDir%\%datProc%_%appName%_%mode%_%tools%_log.txt

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

echo Source folder:  %srcDir%
echo Source folder:  %srcDir% >> %log%
echo Running mode :  %mode%
echo Running mode :  %mode% >> %log%
echo Ext. tools   :  %tools%
echo Ext. tools   :  %tools% >> %log%
echo PSP level :  %level%
echo PSP level :  %level% >> %log%
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

echo Processing ... %mode% ... %srcDir% ... level %level%
echo.
cd /D %srcDir%

setlocal enabledelayedexpansion

if %level%==0 (

echo %srcDir%
echo %srcDir% >> %log%

set /a totalFolders += 1

for %%I in (.) do set base_dir=%%~nxI

call:validate_psp %srcDir% %repDir%\!base_dir!
goto:finished
)

for /f "tokens=*" %%A in ('dir /b /ad') do (

echo %%A

if %level%==1 (

set /a totalFolders += 1
set base_dir=%%A

echo %%A >> %log%
call:validate_psp %srcDir%\!base_dir! %repDir%\!base_dir!
)

if %level%==2 (
for /f "tokens=*" %%B in ('dir %%A /b /ad') do (

set /a totalFolders += 1
set base_dir=%%A\%%B
set base_rep=%%A_%%B

echo %%A	%%B >> %log%
call:validate_psp %srcDir%\!base_dir! %repDir%\!base_rep!
)
) 

if %level%==3 (
for /f "tokens=*" %%B in ('dir %%A /b /ad') do (
for /f "tokens=*" %%C in ('dir %%A\%%B /b /ad') do (

set /a totalFolders += 1
set base_dir=%%A\%%B\%%C
set base_rep=%%A_%%B_%%C

echo %%A	%%B	%%C >> %log%
call:validate_psp %srcDir%\!base_dir! %repDir%\!base_rep!
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
echo Finished   :   %date%  %time%
echo Finished   :   %date%  %time% >> %log%
echo.
echo Log file   :   %log%
echo Log file   :   %log% >> %log%
echo Report dir :   %repDir%
echo Report dir :   %repDir% >> %log%
if not %mode%==group (
echo.
echo Processed  :   %totalFolders%  Folders
echo Processed  :   %totalFolders%  Folders >> %log%
)
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
echo    %appName% sourceFolder psplevel mode tools [verbosity]    
echo  Params:
echo    1 :  Source folder full path
echo    2 :  Steps to reach a PSP subfolder:  0-3 
echo    3 :  Running mode: group / single / test 
echo    4 :  Use ext. tools:  none images im jhove jpyl kdu jhove_jpyl - default: none
echo    5 :  [optional] Verbosity:  1-3  - default: 2

echo.
echo  Examples:
echo    %appName% D:\some\data 1 group none
echo    %appName% D:\some\data 2 group images
echo    %appName% D:\some\data 1 single im
echo    %appName% D:\some\data 3 test kdu 3
echo.
goto:eof


:validate_psp
if %mode%==group (
cd /D %runDir%
echo. >> %log%
REM Not working properly - see https://github.com/NLCR/komplexni-validator/issues/156
echo java -jar %validator% %val_group% "%1" --xml-protocol-dir "%2" --tmp-dir %tempDir% %val_tools% %val_disabled% >> %log%
echo. >> %log%
)
if %mode%==single (
cd /D %runDir%
echo. >> %log%
java -jar %validator% %val_psp% "%1" --xml-protocol-file "%2_protocol.xml" --tmp-dir %tempDir% %val_tools% %val_disabled% >> %log%
echo. >> %log%
)
if %mode%==test (
cd /D %runDir%
echo. >> %log%
echo java -jar %validator% %val_psp% "%1" --xml-protocol-file "%2_protocol.xml" --tmp-dir %tempDir% %val_tools% %val_disabled% >> %log%
echo. >> %log%
)

