#!/bin/bash

if [[ $# -eq 0 || $# -gt 1 ]]; then
    echo "Usage: bash run.sh nb_tasks"
    echo "Where nb_tasks is the number of MPI tasks for HPCG"
    read -p "Enter the number of MPI tasks for HPCG: " NB_TASKS
else
    NB_TASKS=$1
fi
echo -e "Using ${NB_TASKS} MPI tasks"

export OMP_NUM_THREADS=1
echo -e "Using $OMP_NUM_THREADS OpenMP thread per task"

# Change directory to the current scripts directory
cd "$(dirname "$0")"

# Execute the benchmark test without specific bindings to cores
mpirun -n ${NB_TASKS} ./xhpcg

# Execute the benchmark test with specific bindings to cores
# Make sure that the myrankfile is placed in the same directory
#mpirun -rf myrankfile --report-bindings ./xhpcg

# Output the result

outFile=$(ls -1 *3.1_*.txt | tail -1)
status=$(echo $(grep 'Result=' $outFile | cut -d= -f2) | tr ' ' '*')
final=$(grep 'Final Summary::HPCG result' $outFile | tr '=' ' ' | cut -d' ' -f5,11)
valid=$(echo $final | cut -d' ' -f1)
gflop=$(echo $final | cut -d' ' -f2)

echo Test,Hostname,Timestamp,Status,Gflops
echo HPCG-CPU,$(hostname),$(date '+%F %T'),$status'='$valid,$gflop
