#!/bin/bash

#prepare test folder
TEST_DIR="./test_log"
rm -rf "$TEST_DIR" #delete older folder
mkdir -p "$TEST_DIR"

echo "Generate test data(0,5 GB). It takes some time, please wait.."

#create files
#dd = data generator, of = file, bs = block size
#create 5 files with 100 Mb size
for i in {1..5}; do
	dd if=/dev/zero of="$TEST_DIR/file_$i.bin" bs=1M count=100 status=none
#change modification time for sorting test
done


echo "Data generated."

#run the main script
#set threshold to 1% to ensure the test triggers
echo "Running main.sh with a 1% threshold..."
./main.sh "$TEST_DIR" 1

#check results
echo "Checking results..."

#check if the archive was created in the backup folder
if [ -f ./backup/*.tar.gz ]; then
	echo "TEST PASSED: Archive created."
else
	echo "TEAT FAILED: Archive not found"
fi

#check if files were deleted from test_log
COUNT_FILES=$(ls "$TEST_DIR" | wc -l)
if [ "$COUNT_FILES" -lt 5 ]; then
	echo "TEST PASSED: Files deleted."
else
	echo "TEST FAILED: Files remain in place."
fi
