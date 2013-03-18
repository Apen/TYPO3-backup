#!/bin/sh

##########################################################################
# (c) 2013 Yohann CERDAN <cerdanyohann@yahoo.fr>
# All rights reserved
#
# This program is free software : you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# The GNU General Public License can be found at
# http://www.gnu.org/copyleft/gpl.html.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
##########################################################################

# Decode all args
decodeArgs () {
	while [ $# -gt 0 ]
	do
		case $1 in
			"-f")
				shift
				force=1
				;;
			"-p")
				shift
				if [ "$1" != "" ] 
				then 
					cd $1
				else 
					echo "The path to the site root is invalid"
				fi
				shift
				;;
			"-o")
				shift
				if [ "$1" != "" ] 
				then 
					path_save=$1
				else 
					echo "The path of the save dir is invalid"
				fi
				shift
				;;
			"-sql")
				shift
				if [ "$1" != "" ] 
				then 
					path_sql=$1
				else 
					echo "The filename of the sql save file is invalid"
				fi
				shift
				;;
			"-h")
				shift
				echo "-----------------------------------------------------------------------"
				echo "TYPO3 backup"
				echo "-----------------------------------------------------------------------"
				echo "All the parameters are optionnals :"
				echo "-f          : force save without confirmation"
				echo "-p <path>   : path of the site root directory"
				echo "-o <output> : path of the save file directory with final /"
				echo "-sql <sql>  : filename of the sql file .sql"
				exit
				;;
			*)
				shift
				;;
		esac
	done
}

# Check for dependencies
checkDependency() {
  if ! hash $1 2>&-; then
    echo "Failed!"
    echo "This script requires '$1' but it can not be found. Aborting." >&2
    exit 1
  fi
}

date 

echo -n "Checking dependencies..."
checkDependency "grep"
checkDependency "sed"
checkDependency "date"
checkDependency "du"
checkDependency "mysql"
checkDependency "mysqldump"
checkDependency "tar"
checkDependency "rm"
checkDependency "awk"
echo "Succeeded."

# force
force=0
path_save=''
path_sql=''

decodeArgs $*

# path of localconf
path_localconf='typo3conf/localconf.php'
path_config_default='t3lib/config_default.php'

# username, password, host & db
typo_db_username=$(grep "typo_db_username =*" $path_localconf  | sed 's/$typo_db_username = '\''\([^\;]*\)'\'';.*/\1/');
typo_db_password=$(grep "typo_db_password =*" $path_localconf  | sed 's/$typo_db_password = '\''\([^\;]*\)'\'';.*/\1/');
typo_db_host=$(grep "typo_db_host =*" $path_localconf  | sed 's/$typo_db_host = '\''\([^\;]*\)'\'';.*/\1/');
typo_db=$(grep "typo_db =*" $path_localconf  | sed 's/$typo_db = '\''\([^\;]*\)'\'';.*/\1/');

# informations
day_date=$(date +"%Y%m%d")
dir_size=$(du -sh . | sed 's/\.//')
db_size=$(mysql -h$typo_db_host -u$typo_db_username -p$typo_db_password -D$typo_db -e'show table status;' | awk '{sum=sum+$7+$9;} END {print sum/1024/1024}')
typo_version=$(grep "TYPO_VERSION =*" $path_config_default | sed 's/$TYPO_VERSION = '\''\([^\;]*\)'\'';.*/\1/');

# save file .tar.gz
if [ "$path_save" != "" ] 
then
	filename=$path_save
else
	filename='export_'$typo_db'-'$day_date'.tar.gz'
fi

# sql file sql
if [ "$path_sql" != "" ] 
then
	filenamesql=$path_sql
else
	filenamesql='export_'$typo_db'-'$day_date'.sql'
fi

echo "-----------------------------------------------------------------------"
echo "Informations"
echo "-----------------------------------------------------------------------"
echo "Date               : $day_date"
echo "Website size       : $dir_size"
echo "Size of the DB     : "$db_size"M"
echo "TYPO3 version      : $typo_version"
echo "PATH_site          : "$(pwd)
echo "Tar file           : $filename"
echo "SQL file           : $filenamesql"
echo "-----------------------------------------------------------------------"
echo "Check informations in '$path_localconf'"
echo "-----------------------------------------------------------------------"
echo "typo_db_host       : $typo_db_host"
echo "typo_db_username   : $typo_db_username"
echo "typo_db            : $typo_db"

# force
if [ $force = 0 ] 
then
	echo
	echo -n "Do you want to backup the website? (y or n) : "
	read exportok
	if [ $exportok != "y" ]
	then
		exit
	fi  
fi

echo
echo "-----------------------------------------------------------------------"
echo "Dump the DB $typo_db..."
echo "-----------------------------------------------------------------------"
mysqldump -d -h$typo_db_host -u$typo_db_username -p$typo_db_password $typo_db > $filenamesql
mysqldump -nt --ignore-table=$typo_db.cache_extensions --ignore-table=$typo_db.cache_hash --ignore-table=$typo_db.cache_imagesizes --ignore-table=$typo_db.cache_md5params --ignore-table=$typo_db.cache_md5params --ignore-table=$typo_db.cache_pages --ignore-table=$typo_db.cache_pagesection --ignore-table=$typo_db.cache_treelist --ignore-table=$typo_db.cache_typo3temp_log -h$typo_db_host -u$typo_db_username -p$typo_db_password $typo_db >> $filenamesql

echo "-----------------------------------------------------------------------"
echo "Compress the files and DB..."
echo "-----------------------------------------------------------------------"
tar cfz $filename * .htaccess

echo "-----------------------------------------------------------------------"
echo "Delete export_$typo_db-$day_date.sql..."
echo "-----------------------------------------------------------------------"
rm $filenamesql

echo "-----------------------------------------------------------------------"
echo -n "Backup success: "
echo $(pwd)"/"$filename
echo "-----------------------------------------------------------------------"

date