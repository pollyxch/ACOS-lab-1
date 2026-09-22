#!/bin/bash

#arguments check

if ["$#" -lt 2]; then
	echo "needed: $0 <path to folder> <limit in percent>"
	exit 1
fi

TARGET_DIR=$1
LIMIT=$2
BACKUP_DIR="./backup" #folder for backup, if none creating it

mkdir -p "$BACKUP_DIR"

#calculation of filled space

USAGE=$(df -h "$TARGET_DIR" | tail -1 | awk '{print $5}' | sed 's/%//')

echo "current % of filled space $TARGET_DIR: ${USAGE}%"

