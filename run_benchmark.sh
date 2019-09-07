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

url=$1
folder_name=$2

for number_of_requests in {1000,2000,5000,10000}; do
  for concurrency in {1,10,25,50,100,200}; do
    echo 'running' $number_of_requests 'requests with concurrency' $concurrency

    path="$(pwd)/apache_benchmarks/"$folder_name'/'
    # make the directory if it doesnt exist else leave it as it is
    mkdir -p $path

    file_name='bm_c_'$concurrency'_n_'$number_of_requests

    full_path=$path$file_name
    # Run the apache benchmark test with -c to set concurrency
    # -r to not exit if we get socket errors
    # -n to control how many requests to send
    # write all the output inside a folder of the form '100_requests/bm_10.txt' where 10 is concurrency
    ab -r -c $concurrency -n $number_of_requests -g $full_path.tsv  $url > $full_path.txt

    # Plot the normal graph
    # First argument is path where image file must be stored
    # Second argument is title of the GNU plot
    # Third argument is the location where it can find the .tsv file containing data
    gnuplot -c plot_graph.gp $full_path'_graph'.png $folder_name' concurrency '$concurrency' requests '$number_of_requests $full_path.tsv

    # Plot the SCATTER graph
    # First argument is path where image file must be stored
    # Second argument is title of the GNU plot
    # Third argument is the location where it can find the .tsv file containing data
    gnuplot -c plot_scatter.gp $full_path'_scatter'.png $folder_name' concurrency '$concurrency' requests '$number_of_requests $full_path.tsv

    

  done;
done;