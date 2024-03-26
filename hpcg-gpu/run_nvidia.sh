#!/bin/bash

if [ -z "$CUDA_VISIBLE_DEVICES" ]; then
  echo -n "Error: CUDA_VISIBLE_DEVICES is not set. Available devices are: "
  echo $(nvidia-smi -L | tr ':' ' ' | cut -d' ' -f2) | tr ' ' ','
  exit 1
fi
echo -e "Using CUDA devices: $CUDA_VISIBLE_DEVICES"

if [[ $# -eq 0 || $# -gt 1 ]]; then
    echo "Usage: bash run.sh nb_tasks"
    echo "Where nb_tasks is the number of MPI tasks for HPCG"
    read -p "Enter the number of MPI tasks for HPCG: " NB_TASKS
else
    NB_TASKS=$1
fi
echo -e "Using ${NB_TASKS} MPI tasks"

export OMP_NUM_THREADS=1
echo -e "Using $OMP_NUM_THREADS OpenMP threads"

# Change directory to the current scripts directory
cd "$(dirname "$0")"

# Execute the benchmark test
mpirun -n ${NB_TASKS} ./xhpcg > progress.log

# Output the result

outFile=$(ls -1 HPCG-Benchmark_3.1* | tail -1)
status=$(echo $(grep 'Result=' $outFile | cut -d= -f2) | tr ' ' '*')
final=$(grep 'Final Summary::HPCG result' $outFile | tr '=' ' ' | cut -d' ' -f5,11)
valid=$(echo $final | cut -d' ' -f1)
gflop=$(echo $final | cut -d' ' -f2)

echo Test,Hostname,Timestamp,Status,Gflops
echo HPCG-GPU,$(hostname),$(date '+%F %T'),$status'='$valid,$gflop
