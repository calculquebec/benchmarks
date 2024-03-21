#!/bin/bash

if [[ $# -eq 0 || $# -gt 1 ]]; then
    echo "This test runs multiple NAMD executables in parallel, each having 1 GPU assigned"
    echo "Usage: bash run.sh nb_threads"
    echo "Where nb_threads is the number of threads for each NAMD executable"
    read -p "Enter the number of threads for each NAMD: " NB_THREADS
else
    NB_THREADS=$1
fi

# Change directory to the current scripts directory
cd "$(dirname "$0")"

# Execute the benchmark test

for GPU_ID in $(nvidia-smi -L | tr : ' ' | cut -d' ' -f2); do
  echo -n > result_namd-gpu_${GPU_ID}.txt
  echo "Using ${NB_THREADS} threads with GPU ID $GPU_ID"
  ./namd3 +p${NB_THREADS} +idlepoll +devices $GPU_ID stmv_gpu/stmv_gpures_cq.namd >> result_namd-gpu_${GPU_ID}.txt &
done
wait

# Output the result
RESULT=$(awk '/Benchmark time/ {a+=1.0/$6;i++} END {print a/i}' result_namd-gpu_*.txt)

echo Test,Hostname,Timestamp,NbThreads,StepsPerSec
echo NAMD-1-GPU,$(hostname),$(date '+%F %T'),$NB_THREADS,$RESULT
