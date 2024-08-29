#!/bin/bash

echo "BUILDING"

make clean
make

date=$(date +"%Y-%m-%d_%H-%M")
logfile="log_gc_${date}.log"

if [ -n "$1" ]; then
   logfile=$1
fi


echo "PERFORMING TESTS: " $date

expected_fails=("test_lisp_code_cps -t 25 -h 1024 tests/test_take_iota_0.lisp"
                "test_lisp_code_cps -t 25 -s -h 1024 tests/test_take_iota_0.lisp"
                "test_lisp_code_cps -t 25 -h 512 tests/test_take_iota_0.lisp"
                "test_lisp_code_cps -t 25 -s -h 512 tests/test_take_iota_0.lisp"
                "test_lisp_code_cps -t 25 -i -h 1024 tests/test_take_iota_0.lisp"
                "test_lisp_code_cps -t 25 -i -s -h 1024 tests/test_take_iota_0.lisp"
                "test_lisp_code_cps -t 25 -i -h 512 tests/test_take_iota_0.lisp"
                "test_lisp_code_cps -t 25 -i -s -h 512 tests/test_take_iota_0.lisp"
               )


success_count=0
fail_count=0
failing_tests=()
result=0

for exe in *.exe; do

    if [ "$exe" = "test_gensym.exe" ]; then
        continue
    fi

    ./$exe

    result=$?

    echo "------------------------------------------------------------"
    if [ $result -eq 1 ]
    then
        success_count=$((success_count+1))
        echo $exe SUCCESS
    else

        fail_count=$((fail_count+1))
        echo $exe FAILED
    fi
    echo "------------------------------------------------------------"
done

test_config=("-t 25 -h 32768"
             "-t 25 -i -h 32768"
              "-t 25 -s -h 32768"
              "-t 25 -i -s -h 32768"
              "-t 25 -h 16384"
              "-t 25 -i -h 16384"
              "-t 25 -s -h 16384"
              "-t 25 -i -s -h 16384"
              "-t 25 -h 8192"
              "-t 25 -i -h 8192"
              "-t 25 -s -h 8192"
              "-t 25 -i -s -h 8192"
              "-t 25 -h 4096"
              "-t 25 -i -h 4096"
              "-t 25 -s -h 4096"
              "-t 25 -i -s -h 4096"
              "-t 25 -h 2048"
              "-t 25 -i -h 2048"
              "-t 25 -s -h 2048"
              "-t 25 -i -s -h 2048"
              "-t 25 -h 1024"
              "-t 25 -i -h 1024"
              "-t 25 -s -h 1024"
              "-t 25 -i -s -h 1024"
              "-t 25 -h 512"
              "-t 25 -i -h 512"
              "-t 25 -s -h 512"
              "-t 25 -i -s -h 512")

for prg in "test_lisp_code_cps" ; do
    for arg in "${test_config[@]}"; do
        echo "Configuration: " $arg
        for lisp in tests/*.lisp; do
            tmp_file=$(mktemp)
            ./$prg $arg $lisp > $tmp_file
            result=$?
            if [ $result -eq 1 ]
            then
                success_count=$((success_count+1))
            else
                failing_tests+=("$prg $arg $lisp")
                fail_count=$((fail_count+1))

                echo $lisp FAILED
                cat $tmp_file >> $logfile
            fi
            rm $tmp_file
        done
    done
done

# echo -e $failing_tests

expected_count=0

for (( i = 0; i < ${#failing_tests[@]}; i++ ))
do
  expected=false
  for (( j = 0; j < ${#expected_fails[@]}; j++))
  do

      if [[ "${failing_tests[$i]}" == "${expected_fails[$j]}" ]] ;
      then
          expected=true
      fi
  done
  if $expected ; then
      expected_count=$((expected_count+1))
      echo "(OK - expected to fail)" ${failing_tests[$i]}
  else
      echo "(FAILURE)" ${failing_tests[$i]}
  fi
done


echo Tests passed: $success_count
echo Tests failed: $fail_count
echo Expected fails: $expected_count
echo Actual fails: $((fail_count - expected_count))

if [ $((fail_count - expected_count)) -gt 0 ]
then
    exit 1
fi
