#!/bin/bash

# TEST 1: Above threshold
echo -e "\nTEST 1: Above threshold"

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
ARCHIVE_COUNT=$(ls ./backup/*.tar.gz 2>/dev/null | wc -l)
if [ "$ARCHIVE_COUNT" -gt 0 ]; then
	echo "TEST 1 PASSED: Archive created."
else
	echo "TEAT 1 FAILED: Archive not found"
fi

#check if files were deleted from test_log
COUNT_FILES=$(ls "$TEST_DIR" | wc -l)
if [ "$COUNT_FILES" -lt 5 ]; then
	echo "TEST 1 PASSED: Files deleted."
else
	echo "TEST 1 FAILED: Files remain in place."
fi


# TEST 2: Below Threshold
echo -e "\nTEST 2: Below Threshold"
rm -rf "$TEST_DIR" ./backup
mkdir -p "$TEST_DIR"

# Create a single small file (10 MB)
dd if=/dev/zero of="$TEST_DIR/small_file.bin" bs=1M count=10 status=none

echo "Running main.sh with an 80% threshold..."
./main.sh "$TEST_DIR" 80

# Verify no archive was created and the file remains
ARCHIVE_COUNT=$(ls ./backup/*.tar.gz 2>/dev/null | wc -l)
if [ "$ARCHIVE_COUNT" -eq 0 ] && [ -f "$TEST_DIR/small_file.bin" ]; then
    echo "TEST 2 PASSED: Script correctly did nothing."
else
    echo "TEST 2 FAILED: Script acted when it shouldn't."
fi


# TEST 3: Empty Folder with Exceeded Threshold
echo -e "\nTEST 3: Empty Folder"
rm -rf "$TEST_DIR" ./backup
mkdir -p "$TEST_DIR"

# Use -1% threshold to trigger the condition even for an empty folder
echo "Running main.sh on empty folder with -1% threshold..."
./main.sh "$TEST_DIR" -1

# Verify the script didn't crash or create an empty archive
if [ ! -f ./backup/*.tar.gz ]; then
    echo "TEST 3 PASSED: Script handled empty folder gracefully."
else
    echo "TEST 3 FAILED: Created empty archive."
fi


# TEST 4: Sorting (Oldest Files Deleted)
echo -e "\nTEST 4: Sorting Oldest Files"
rm -rf "$TEST_DIR" ./backup
mkdir -p "$TEST_DIR"

# Create 4 files
for i in {1..4}; do
    dd if=/dev/zero of="$TEST_DIR/file_$i.bin" bs=1M count=100 status=none
done

# Change modification times (file_1 is the oldest, file_4 is the newest)
touch -d "5 days ago" "$TEST_DIR/file_1.bin"
touch -d "4 days ago" "$TEST_DIR/file_2.bin"
touch -d "1 hour ago" "$TEST_DIR/file_3.bin"

echo "Running main.sh. It should delete 3 oldest files and keep file_4..."
./main.sh "$TEST_DIR" 1

# Verify: newest file (file_4) remains, oldest (file_1) is deleted
if [ -f "$TEST_DIR/file_4.bin" ] && [ ! -f "$TEST_DIR/file_1.bin" ]; then
    echo "TEST 4 PASSED: Correct files were archived/deleted."
else
    echo "TEST 4 FAILED: Sorting logic is broken."
fi


# TEST 5: Error Handling (No Arguments)
echo -e "\nTEST 5: Error Handling"
rm -rf "$TEST_DIR" ./backup
mkdir -p "$TEST_DIR"

# Run main.sh without arguments and capture output
OUTPUT=$(./main.sh 2>&1)

# Verify if the output contains the expected usage message
if echo "$OUTPUT" | grep -q "needed"; then
    echo "TEST 5 PASSED: Correct usage message displayed."
else
    echo "TEST 5 FAILED: No usage message."
fi
