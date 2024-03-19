#!/bin/sh

# AMD procedure, based on
# http://www.crc.nd.edu/~rich/CRC_EPYC_Cluster_Build_Feb_2018/Installing%20and%20running%20HPL%20on%20AMD%20EPYC%20v2.pdf

# OpenMP environment variables
# Use explicit process binding
export OMP_PROC_BIND=TRUE
# Have OpenMP ignore SMT siblings if SMT is enabled
export OMP_PLACES=cores
# Determine number of threads per L3 cache. Look for total number of
# L3 caches and divide total number of cores by this
l3caches=$(lscpu | awk '/L3 cache:/{print $5}' | sed s'/(//')
corespersocket=$( lscpu | awk '/Core\(s\) per socket:/{print $4}' )
sockets=$( lscpu | awk '/Socket\(s\):/{print $2}' )
echo "$(( $sockets * $corespersocket )) core processors detected"
cores=$(( $sockets * $corespersocket / $l3caches ))
echo "Using $cores cores (threads) per process"
export OMP_NUM_THREADS=$cores

# BLIS library environment variables
# DGEMM parallelization is performed at the 2nd innermost loop (IC)
export BLIS_IR_NT=1
export BLIS_JR_NT=1
export BLIS_IC_NT=$cores
export BLIS_JC_NT=1

# OpenMPI settings
# Launch as one process per L3 cache
mpi_options="-np $l3caches"
# Use vader for Byte Transfer Layer
mpi_options+=" --mca btl self,vader"
# Map processes to L3 cache
# Note if SMT is enabled, the resource list given to each process will include
# the SMT siblings! See OpenMP options above.
mpi_options+=" --map-by l3cache"
# Show bindings
mpi_options+=" --report-bindings"

MPIRUN=/cvmfs/soft.computecanada.ca/easybuild/software/2023/x86-64-v3/Compiler/gcc12/openmpi/4.1.5/bin/mpirun
if [ ! -x $MPIRUN ]; then
    MPIRUN=mpirun
fi

$MPIRUN $mpi_options amd-zen-hpl-2023_07_18/xhpl > hpl.log 2>&1
