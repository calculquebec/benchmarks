#!/bin/bash

### Editable OpenMP and other CPU affinity options ###

export KMP_AFFINITY=compact
export OMP_DYNAMIC=false    # Disable dynamic thread pool sizing
export OMP_SCHEDULE=static  # Disable dynamic loop scheduling
export OMP_PROC_BIND=TRUE   # Bind threads to specific resources
export OMP_PLACES=0:32:2    # Stride by 2 cores
export OMP_NUM_THREADS=32   # Only half cores are used

######################################################

RESULT=$(./stream.exe | awk '
  BEGIN                  {triad_best=0}
  /^Triad:/              {triad_best=$2}
  /^Solution Validates:/ {print triad_best}
  /^Failed Validation/   {print "FAILED"}
')

echo Test,Hostname,Timestamp,BestRate
echo Stream-CPU,$(hostname),$(date '+%F %T'),$RESULT
