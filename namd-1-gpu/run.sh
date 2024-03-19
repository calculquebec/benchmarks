#!/bin/bash

if [[ $# -eq 0 || $# -gt 1 ]]; then
    echo "Usage: bash run.sh nb_threads"
    echo "Where nb_threads is the number of threads for NAMD"
    read -p "Enter the number of threads for NAMD: " NB_THREADS
else
    NB_THREADS=$1
fi
echo "Using ${NB_THREADS} threads with 1 GPU"

# Change directory to the current scripts directory
cd "$(dirname "$0")"

# Execute the benchmark test
echo -n > result_namd-gpu.txt

for GPU_ID in $(nvidia-smi -L | tr : ' ' | cut -d' ' -f2); do
  ./namd2 +p${NB_THREADS} +idlepoll +devices $GPU_ID stmv/stmv.namd >> result_namd-gpu.txt
done

# Output the result
RESULT=$(awk '/Benchmark time/ {a+=1.0/$6;i++} END {print a/i}' result_namd-gpu.txt)

echo Test,Hostname,Timestamp,NbThreads,StepsPerSec
echo NAMD-1-GPU,$(hostname),$(date '+%F %T'),$NB_THREADS,$RESULT
