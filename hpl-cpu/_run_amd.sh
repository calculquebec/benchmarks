#!/bin/sh

# AMD procedure, based on
# http://www.crc.nd.edu/~rich/CRC_EPYC_Cluster_Build_Feb_2018/Installing%20and%20running%20HPL%20on%20AMD%20EPYC%20v2.pdf

# OpenMP environment variables
# Use explicit process binding
export OMP_PROC_BIND=TRUE
# Have OpenMP ignore SMT siblings if SMT is enabled
export OMP_PLACES=cores
# Determine number of threads per L3 cache. Count cores per socket and
# divide by 8 (8 L3s per socket)
cores=$( lscpu | grep "Core(s) per socket" | awk '{print $4}' )
echo "$cores core processors detected"
cores=$(( $cores / 8 ))
export OMP_NUM_THREADS=$cores

# BLIS library environment variables
# DGEMM parallelization is performed at the 2nd innermost loop (IC)
export BLIS_IR_NT=1
export BLIS_JR_NT=1
export BLIS_IC_NT=$cores
export BLIS_JC_NT=1

# OpenMPI settings
# Launch 16 processes (one per L3 cache, two L3 per die, 4 die per socket, 2 sockets)
mpi_options="-np 16"
# Use vader for Byte Transfer Layer
mpi_options+=" --mca btl self,vader"
# Map processes to L3 cache
# Note if SMT is enabled, the resource list given to each process will include
# the SMT siblings! See OpenMP options above.
mpi_options+=" --map-by l3cache"
# Show bindings
mpi_options+=" --report-bindings"

export LD_LIBRARY_PATH=amd-blis/lib:aocc-compiler-2.2.0/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
MPIRUN=/cvmfs/soft.computecanada.ca/easybuild/software/2020/avx2/Compiler/gcc9/openmpi/4.0.3/bin/mpirun
if [ ! -x $MPIRUN ]; then
    MPIRUN=mpirun
fi

$MPIRUN $mpi_options amd-hpl-blis-aocc/xhpl > hpl.log
