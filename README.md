About
-----

This script allow you to backup all the files and the database of your TYPO3 installation.

Installation
------------

1] Upload the script to your website directory (the same as global index.php) OR download the script with wget:
```
wget "https://raw.github.com/Apen/TYPO3-backup/master/save-typo3.sh"
```

2] Allow your user to execute this script with a chmod

3] Execute the script
```
/home/html/dev/packagedev# ./save-typo3.sh
```

Example of execution
------------

	-----------------------------------------------------------------------
	Informations
	-----------------------------------------------------------------------
	Date               : 20120406
	Website size       : 137M
	Size of the DB     : 21.4624M
	TYPO3 version      : 4.6.7
	PATH_site          : /home/html/dev/packagedev
	Save file          : export_dev_packagedev-20120406.tar.gz
	SQL file           : export_dev_packagedev-20120406.sql
	-----------------------------------------------------------------------
	Informations in 'typo3conf/localconf.php'
	-----------------------------------------------------------------------
	typo_db_host       : localhost
	typo_db_username   : ***
	typo_db            : dev_packagedev

	Do you want to backup the website? (y or n) : y
	-----------------------------------------------------------------------
	Export the DB dev_packagedev...
	-----------------------------------------------------------------------
	-----------------------------------------------------------------------
	Compress the files and DB...
	-----------------------------------------------------------------------
	-----------------------------------------------------------------------
	Delete export_dev_packagedev-20120406.sql...
	-----------------------------------------------------------------------
	-----------------------------------------------------------------------
	Backup success
	/home/html/dev/packagedev/export_dev_packagedev-20120406.tar.gz
	-----------------------------------------------------------------------
