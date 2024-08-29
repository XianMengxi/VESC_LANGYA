#!/bin/bash

release=$1

if [ -z "$1" ]; then
    echo "No arg"
    exit 1
fi
   

reportdir=./test_reports/version_$release

echo $release
echo $reportdir

mkdir -p $reportdir
mkdir -p $reportdir/scan-build

cd tests

unit_tests_log_file="unit_tests_log_${release}.txt"
failing_unit_tests_log_file="failing_unit_tests_log_${release}.txt"

unit_tests_64_log_file="unit_tests_log_64_${release}.txt"
failing_unit_tests_64_log_file="failing_unit_tests_log_64_${release}.txt"

gc_unit_tests_log_file="gc_unit_tests_log_${release}.txt"
failing_gc_unit_tests_log_file="failing_gc_unit_tests_log_${release}.txt"


./run_tests.sh ../$reportdir/$failing_unit_tests_log_file >> ../$reportdir/$unit_tests_log_file
./run_tests.sh ../$reportdir/$failing_unit_tests_64_log_file >> ../$reportdir/$unit_tests_64_log_file
./run_tests_gc.sh ../$reportdir/$failing_gc_unit_tests_log_file >> ../$reportdir/$gc_unit_tests_log_file

cd ..

if ! command -v scan-build-14 &> /dev/null
then
    if ! command -v scan-build-10 &> /dev/null
    then
    
        echo "<the_command> could not be found"
        exit 1
    else
        make clean
        scan-build-10 -o ./$reportdir/scan-build make -j4
    fi
else
    make clean
    scan-build-14 -o ./$reportdir/scan-build make -j4
fi


make clean 
infer run -- make

cp ./infer-out/report.txt $reportdir/infer_${release}.txt
