# PSP-Validator-batch

## Usage

Download or clone this repo.

Open CMD - go to the repo dir and run:

      validate.bat ?

      validate.bat <srcDir> <pspLevel>

> Remove any diacritics and spaces from the srcDir and its subfolders !

pspLevel = 1 - single doc

     <srcDir>\<pspDir>

pspLevel = 2 - multiple docs or single periodical

     <srcDir>\<docDir>\<pspDir>
     <srcDir>\<YYYY>\<pspDir>

pspLevel = 3 - multiple periodicals

     <srcDir>\<docDir>\<YYYY>\<pspDir>

## Building the validator client

1. Download the project https://github.com/NLCR/komplexni-validator/archive/refs/heads/master.zip

2. Extract to dir komplexni-validator-master

3. Open the dir in CMD

4. Run gradlew.bat for gradle installation

5. Build - run in CMD:

     > ...\komplexni-validator-master\cliModule>..\gradlew fatJar

- jars in: 

     ...\komplexni-validator-master\cliModule\build\libs\       

