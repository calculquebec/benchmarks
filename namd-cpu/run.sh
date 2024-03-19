#!/bin/bash

if [[ $# -eq 0 || $# -gt 1 ]]; then
    echo "Usage: bash run.sh nb_threads"
    echo "Where nb_threads is the number of threads for NAMD"
    read -p "Enter the number of threads for NAMD: " NB_THREADS
else
    NB_THREADS=$1
fi
echo "Using ${NB_THREADS} threads"

# Change directory to the current scripts directory
cd "$(dirname "$0")"

# Execute the benchmark test
./namd2 +p${NB_THREADS} stmv/stmv.namd > result_namd-cpu.txt

# Output the result
RESULT=$(awk '/Benchmark time/ {a+=1.0/$6;i++} END {print a/i}' result_namd-cpu.txt)

echo Test,Hostname,Timestamp,NbThreads,StepsPerSec
echo NAMD-CPU,$(hostname),$(date '+%F %T'),$NB_THREADS,$RESULT
