# PSP-Validator-batch

## Usage

Download or clone this repo.

Open CMD - go to the repo dir and run:

     ...\PSP-Validator-batch> validate.bat ?

     ...\PSP-Validator-batch> validate.bat <srcDir> <pspLevel> <phase> [<verbosity>]

> Remove any diacritics and spaces from the srcDir and its subfolders !

srcDir - full path to a folder with PSP packages

phase:
- base = do not validate images
- all = validate all

pspLevel = 1 - single doc

     <srcDir>\<pspDir>

pspLevel = 2 - multiple docs or single periodical

     <srcDir>\<docDir>\<pspDir>
     <srcDir>\<YYYY>\<pspDir>

pspLevel = 3 - multiple periodicals

     <srcDir>\<docDir>\<YYYY>\<pspDir>

verbosity: 1-3     

## Building the validator client

1. Download the project https://github.com/NLCR/komplexni-validator/archive/refs/heads/master.zip

2. Extract to dir komplexni-validator-master

3. Open the dir in CMD

4. Run gradlew.bat for gradle installation

5. Build - run in CMD:

       ...\komplexni-validator-master\cliModule>..\gradlew fatJar

6. Get the KomplexniValidatorCLI-X.X.jar from: 

       ...\komplexni-validator-master\cliModule\build\libs\       

