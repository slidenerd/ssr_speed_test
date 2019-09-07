#!/bin/bash

# https://unix.stackexchange.com/questions/32290/pass-command-line-arguments-to-bash-script
# We test one server at a time REMEMBER?
# So pass the URL of the server as argument and we are solid
if [ $# -ne 2 ]; then
    echo $0: usage: ./run_benchmark.sh url nickname
    echo $0: example: ./run_benchmark.sh http://192.168.1.104:9001/ plain_express
    echo $0: tips: trailing slash is compulsory after port number, nickname will be included as part of the file name
    exit 1
fi

for r in {100,200,300}; do
  for c in {1,10,25}; do
    echo 'running' $r 'requests with concurrency' $c

    # make the directory if it doesnt exist else leave it as it is
    mkdir -p "$(pwd)/apache_benchmarks/"$r'_requests'

    # Run the apache benchmark test with -c to set concurrency
    # -r to not exit if we get socket errors
    # -n to control how many requests to send
    # write all the output inside a folder of the form '100_requests/bm_10.txt' where 10 is concurrency
    ab -r -c $c -n $r $1 > "$(pwd)/apache_benchmarks/"$r'_requests/bm_c_'$c'_'$2.txt
  done;
done;