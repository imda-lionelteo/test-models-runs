#!/bin/sh

echo "=== Moonshot Commands Script Started ==="
# Define lists for matrix execution (POSIX-compliant)
RUN_IDS="my-run-1 my-run-2 my-run-3 my-run-4"
TEST_NAMES="sample_test"
MODELS="my-gpt-4o my-gpt-4o-mini my-gpt-o1 my-gpt-o1-mini"

echo "=== Starting Matrix Execution ==="
# Matrix execution: run all combinations
run_counter=1
for test in $TEST_NAMES; do
    for model in $MODELS; do
        # Get the run_id based on counter (POSIX-compliant way)
        current_run=1
        for run_id in $RUN_IDS; do
            if [ $current_run -eq $run_counter ]; then
                break
            fi
            current_run=$((current_run + 1))
        done
        
        echo "Running: moonshot run $run_id $test $model"
        moonshot run "$run_id" "$test" "$model" || echo "Command failed: moonshot run $run_id $test $model"
        run_counter=$((run_counter + 1))
        
        # Reset counter if we exceed available run IDs (count words in RUN_IDS)
        run_ids_count=$(echo $RUN_IDS | wc -w)
        if [ $run_counter -gt $run_ids_count ]; then
            run_counter=1
        fi
    done
done
echo "=== Moonshot Commands Script Completed ==="