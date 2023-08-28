#!/bin/bash

run_locust() {
    shape=$1
    host=$2
    output_dir=$3
    mkdir -p $output_dir
    locust --host=$2 --locustfile=locustfile.py,load_shapes/$shape.py --headless --csv=$output_dir/$shape-stats
}

# Iterate over each load shaspe and run the test
for shape in "constant" "incremental" "random" "spike"; do
    echo "Running $shape load test..."
    run_locust "$shape" "https://runtime.sagemaker.us-east-1.amazonaws.com/endpoints/mobilenet/invocations" results
    echo "$shape load test completed."

    sleep 15m
done
