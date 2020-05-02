# TYPO3 website backup (files & database)

## About

This script allow you to backup all the files and the database of your TYPO3 installation.
It work with TYPO3 4.x - 10.4.x.

## Installation

1. Upload the script to your website directory (the same as global index.php) OR download the script with wget:

   
    wget --no-check-certificate "https://raw.github.com/Apen/TYPO3-backup/master/save-typo3.sh"
   

2. Allow your user to execute this script with a chmod

3. Execute the script

basic execution

   
    ./save-typo3.sh
   

backup from a passed typo3 directory

   
    ./save-typo3.sh -p "/home/html/package/"
   

backup to a specify directory

   
    ./save-typo3.sh -o "/home/html/package6/"
   

backup with a special name for sql file

   
    ./save-typo3.sh -sql "dump.sql"
   

backup databse only

   
    ./save-typo3.sh -f -dbonly
   

backup without confirmation

   
    ./save-typo3.sh -f
   

## Example of execution

	-----------------------------------------------------------------------
    Informations
    -----------------------------------------------------------------------
    Date               : 20200502
    Website size       : 141M
    Size of the DB     : 4.26562M
    TYPO3 version      : 10.4.1
    PATH_site          : /var/www/package-10.dev/www/public
    Tar file           : export_package10-20200502.tar.gz
    SQL file           : export_package10-20200502.sql
    -----------------------------------------------------------------------
    Check informations in 'typo3conf/LocalConfiguration.php'
    -----------------------------------------------------------------------
    typo_db_host       : 127.0.0.1
    typo_db_username   : typo3
    typo_db            : package10
    
    Do you want to backup the website? (y or n) : y
    
    -----------------------------------------------------------------------
    Dump the DB package10...
    -----------------------------------------------------------------------
    -----------------------------------------------------------------------
    Compress the files and DB...
    -----------------------------------------------------------------------
    -----------------------------------------------------------------------
    Delete export_package10-20200502.sql...
    -----------------------------------------------------------------------
    -----------------------------------------------------------------------
    Backup success: /var/www/package-10.dev/www/public/export_package10-20200502.tar.gz
    -----------------------------------------------------------------------

