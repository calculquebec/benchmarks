#!/bin/bash

REQ_VERSION="2024.0"

if [ -z "$MKLROOT" ]; then
  echo "Error: MKLROOT is not set, i.e. the path to your installation of Intel MKL $REQ_VERSION"
  exit 1
fi

MKL_VERSION=$(awk '/__INTEL_MKL__/ {v=$3} /__INTEL_MKL_UPDATE__/ {print v"."$3}' $MKLROOT/include/mkl_version.h)

echo "Your MKLROOT is now pointing to MKL version $MKL_VERSION:"
echo "    $MKLROOT"

if [ "$MKL_VERSION" != "$REQ_VERSION" ]; then
  echo "Error: MKL version $REQ_VERSION is required."
  exit 2
fi

echo -n "Copying relevant files... "
cp $MKLROOT/share/mkl/benchmarks/mp_linpack/* .

# Calcul Quebec specifics
if [ -x "$(command -v patchelf)" ]; then
    INTELMPI=/cvmfs/soft.computecanada.ca/easybuild/software/2023/x86-64-v3/Compiler/intel2023/intelmpi/2021.9.0
    if [ -d $INTELMPI ]; then
        patchelf --set-rpath $INTELMPI/mpi/latest/lib:$INTELMPI/mpi/latest/lib/release xhpl_intel64_dynamic
    fi
    EPREFIX=/cvmfs/soft.computecanada.ca/gentoo/2023/x86-64-v3
    if [ -d $EPREFIX ]; then
        patchelf --set-interpreter $EPREFIX/lib64/ld-linux-x86-64.so.2 xhpl_intel64_dynamic
    fi
fi

echo 'done!'
