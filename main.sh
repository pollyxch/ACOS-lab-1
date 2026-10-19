#!/bin/bash

#arguments check

if [ "$#" -lt 2 ]; then
	echo "needed: $0 <path to folder> <limit in percent>"
	exit 1
fi

TARGET_DIR=$1
THRESHOLD=$2
BACKUP_DIR="./backup" #folder for backup, if none creating it

mkdir -p "$BACKUP_DIR"

#calculation of filled space

USAGE=$(df -h "$TARGET_DIR" | tail -1 | awk '{print $5}' | sed 's/%//')

echo "current % of filled space $TARGET_DIR: ${USAGE}%"
#3, check
if [ "$USAGE" -gt "$THRESHOLD" ]; then 
	echo "Data exceed the %THRESHOLD%! Arhciving old files... "
	#Finding n old files
	#N = Fixed number (3)
	
	FILES_TO_ARCHIVE=$(ls -t "$TARGET_DIR" | tail -n 3)
	
	if [ -z  "$FILES_TO_ARCHIVE" ]; then
		echo "Folder is empty"
		exit 0
	fi

	echo "The nex files will move to archive:"
	echo "$FILES_TO_ARCHIVE"

	#create name archive with data
	ARCHIVE_NAME="$BACKUP_DIR/archive_$(date +%Y%m%d_%H%M%S).tar.gz"
	#Archivation
	#Use -C 
	tar -czf "$ARCHIVE_NAME" -C "$TARGET_DIR" $FILES_TO_ARCHIVE

	if [ $? -eq 0 ]; then 
		echo "Archivation succesfull: $ARCHIVE_NAME"
		#deleting files from start folder
		for file in $FILES_TO_ARCHIVE; do
			rm "$TARGET_DIR/$file"
			echo "file: $file deleted"
		done
	else
		echo "Archivation error"
	fi
else
	echo "filling in is successfull" 

fi
