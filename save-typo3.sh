#!/bin/bash

##########################################################################
# (c) 2014 Yohann CERDAN <cerdanyohann@yahoo.fr>
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

##########################################################################
# Usage examples :
#  ./save-typo3.sh
#
#### backup from a passed typo3 directory
#  ./save-typo3.sh -p "/home/html/package/"
#
#### backup to a specify directory
#  ./save-typo3.sh -o "/home/html/package6/"
#
#### backup with a special name for sql file
#  ./save-typo3.sh -sql "dump.sql"
#
#### backup database only
#  ./save-typo3.sh -f -dbonly
#
#### backup without confirmation
#  ./save-typo3.sh -f
##########################################################################

# Decode all args
function decodeArgs() {
	while [ $# -gt 0 ]
	do
		case $1 in
			"-f")
				shift
				force=1
			;;
			"-dbonly")
				shift
				dbonly=1
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
				echo "-dbonly     : only save database without compression"
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
function checkDependency() {
	if ! hash $1 2>&-;
	then
		echo "Failed!"
		echo "This script requires '$1' but it can not be found. Aborting."
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
dbonly=0
path_save=''
path_sql=''

decodeArgs $*

# DB configuration
if [ -f typo3conf/LocalConfiguration.php ]
then
	# v6
	path_localconf='typo3conf/LocalConfiguration.php'
	typo_db_username=$(grep "'username' => *" $path_localconf | sed -e "s/\s*'username'\s*=>\s*'\(.*\)'\s*,/\1/");
	typo_db_password=$(grep "'password' => *" $path_localconf | sed -e "s/\s*'password'\s*=>\s*'\(.*\)'\s*,/\1/");
	typo_db_host=$(grep "'host' => *" $path_localconf | sed -e "s/\s*'host'\s*=>\s*'\(.*\)'\s*,/\1/");
	typo_db=$(grep "'database' => *" $path_localconf | sed -e "s/\s*'database'\s*=>\s*'\(.*\)'\s*,/\1/");
else
	# v4
	path_localconf='typo3conf/localconf.php'
	typo_db_username=$(grep "typo_db_username =*" $path_localconf | sed 's/$typo_db_username = '\''\([^\;]*\)'\'';.*/\1/');
	typo_db_password=$(grep "typo_db_password =*" $path_localconf | sed 's/$typo_db_password = '\''\([^\;]*\)'\'';.*/\1/');
	typo_db_host=$(grep "typo_db_host =*" $path_localconf | sed 's/$typo_db_host = '\''\([^\;]*\)'\'';.*/\1/');
	typo_db=$(grep "typo_db =*" $path_localconf | sed 's/$typo_db = '\''\([^\;]*\)'\'';.*/\1/');
fi

# TYPO3 infos
if [ -f typo3/sysext/core/Classes/Core/SystemEnvironmentBuilder.php ]
then
	# v6
	path_config_default='typo3/sysext/core/Classes/Core/SystemEnvironmentBuilder.php'
	typo_version=$(grep "'TYPO3_version',*" $path_config_default | sed "s/.*'TYPO3_version', '\(.*\)');/\1/");
else
	# v4
	path_config_default='t3lib/config_default.php'
	typo_version=$(grep "TYPO_VERSION =*" $path_config_default | sed 's/$TYPO_VERSION = '\''\([^\;]*\)'\'';.*/\1/');
fi

# informations
day_date=$(date +"%Y%m%d")
dir_size=$(du -sh . | sed 's/\.//')
db_size=$(mysql -h$typo_db_host -u$typo_db_username -p$typo_db_password -D$typo_db -e'show table status;' | awk '{sum=sum+$7+$9;} END {print sum/1024/1024}')

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

# configure tables to ignore
ignoretables[0]="cache_extensions"
ignoretables[1]="cache_hash"
ignoretables[2]="cache_imagesizes"
ignoretables[3]="cache_md5params"
ignoretables[4]="cache_pages"
ignoretables[5]="cache_pagesection"
ignoretables[6]="cache_sys_dmail_stat"
ignoretables[7]="cache_treelist"
ignoretables[8]="cache_typo3temp_log"
ignoretables[9]="cf_cache_hash"
ignoretables[10]="cf_cache_hash_tags"
ignoretables[11]="cf_cache_pages"
ignoretables[12]="cf_cache_pages_tags"
ignoretables[13]="cf_cache_pagesection"
ignoretables[14]="cf_cache_pagesection_tags"
ignoretables[15]="cf_cache_rootline"
ignoretables[16]="cf_cache_rootline_tags"
ignoretables[17]="cf_extbase_datamapfactory_datamap"
ignoretables[18]="cf_extbase_datamapfactory_datamap_tags"
ignoretables[19]="cf_extbase_object"
ignoretables[20]="cf_extbase_object_tags"
ignoretables[21]="cf_extbase_reflection"
ignoretables[22]="cf_extbase_reflection_tags"
ignoretables[23]="cf_extbase_typo3dbbackend_tablecolumns"
ignoretables[24]="cf_extbase_typo3dbbackend_tablecolumns_tags"
ignoretables[25]="cachingframework_cache_hash"
ignoretables[26]="cachingframework_cache_hash_tags"
ignoretables[27]="cachingframework_cache_pages"
ignoretables[28]="cachingframework_cache_pages_tags"
ignoretables[29]="cachingframework_cache_pagesection"
ignoretables[30]="cachingframework_cache_pagesection_tags"
ignoretableslist=$(printf " --ignore-table=$typo_db.%s" "${ignoretables[@]}")
ignoretableslist=${ignoretableslist:1}

echo
echo "-----------------------------------------------------------------------"
echo "Dump the DB $typo_db..."
echo "-----------------------------------------------------------------------"
mysqldump -d -h$typo_db_host -u$typo_db_username -p$typo_db_password $typo_db > $filenamesql
mysqldump -nt $ignoretableslist -h$typo_db_host -u$typo_db_username -p$typo_db_password $typo_db >> $filenamesql

if [ $dbonly = 1 ]
then
	echo "-----------------------------------------------------------------------"
	echo -n "Backup success: "
	echo $(pwd)"/"$filenamesql
	echo "-----------------------------------------------------------------------"
	exit
fi

echo "-----------------------------------------------------------------------"
echo "Compress the files and DB..."
echo "-----------------------------------------------------------------------"
tar cfz $filename * .htaccess

echo "-----------------------------------------------------------------------"
echo "Delete $filenamesql..."
echo "-----------------------------------------------------------------------"
rm $filenamesql

echo "-----------------------------------------------------------------------"
echo -n "Backup success: "
echo $(pwd)"/"$filename
echo "-----------------------------------------------------------------------"

date