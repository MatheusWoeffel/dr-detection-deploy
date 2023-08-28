#!/bin/bash

run_locust() {
    shape=$1
    host=$2
    output_dir=$3
    mkdir -p $output_dir
    locust --host=$host --locustfile=locustfile.py,load_shapes/$shape.py --headless --csv=$output_dir/$shape-stats
}

hosts=("https://runtime.sagemaker.us-east-1.amazonaws.com/endpoints/vgg19/invocations")

# Iterate over each host and load shape and run the test
for host in "${hosts[@]}"; do
    for shape in "constant" "incremental" "random" "spike"; do
        echo "Running $shape load test for host $host..."
        output_subdir="${host##*/}" # Extract part of the host URL for output directory
        run_locust "$shape" "$host" "results/$output_subdir"
        echo "$shape load test for host $host completed."

        sleep 15m
    done
done
