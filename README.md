# PSP-Validator-batch

## Usage

Download or clone this repo.

Open CMD - go to the repo dir and run:

```
...\PSP-Validator-batch> validate.bat ?

*** Help ***
 Usage:
   validate sourceFolder psplevel mode tools [verbosity]
 Params:
   1 :  Source folder full path
   2 :  Steps to reach a PSP subfolder:  0-3
   3 :  Running mode: group / single / test
   4 :  Use ext. tools:  none images im jhove jpyl kdu - default: none
   5 :  [optional] Verbosity:  1-3  - default: 2

 Examples:
   validate D:\some\data 1 group none
   validate D:\some\data 2 group images
   validate D:\some\data 1 single im
   validate D:\some\data 3 test kdu 3
```

     ...\PSP-Validator-batch> validate.bat <srcDir> <pspLevel> <mode> <tools> [<verbosity>]

> Remove any diacritics and spaces from the srcDir and its subfolders !

srcDir = full path of a folder with subfolders containing PSP packages

pspLevel = 0 - single PSP dir

     <srcDir> = <pspDir>

pspLevel = 1 - single doc

     <srcDir>\<pspDir>

pspLevel = 2 - multiple docs or single periodical

     <srcDir>\<docDir>\<pspDir>
     <srcDir>\<YYYY>\<pspDir>

pspLevel = 3 - multiple periodicals

     <srcDir>\<docDir>\<YYYY>\<pspDir>

mode
- group = uses --action VALIDATE_PSP_GROUP
- single = uses --action VALIDATE_PSP
- test = uses --action VALIDATE_PSP - no validation - only output commands to log file

tools
- none - no external tools
- images - use all external tools
- im, jhove, jpyl, kdu - use specific tool

verbosity - logging - default: 2
- 1-3     

## Building the validator client

1. Download the project https://github.com/NLCR/komplexni-validator/archive/refs/heads/master.zip

2. Extract to dir komplexni-validator-master

3. Open the dir in CMD

4. Run gradlew.bat for gradle installation

5. Build - run in CMD:

       ...\komplexni-validator-master\cliModule>..\gradlew fatJar

6. Get the KomplexniValidatorCLI-X.X.jar from: 

       ...\komplexni-validator-master\cliModule\build\libs\       

