#!/bin/bash

REQ_VERSION="2020 Update 3"

if [ -z "$MKLROOT" ]; then
  echo "Error: MKLROOT is not set, i.e. the path to your installation of Intel MKL $REQ_VERSION"
  exit 1
fi

MKL_VERSION=$(awk '/__INTEL_MKL__/ {v=$3} /__INTEL_MKL_UPDATE__/ {print v,"Update",$3}' $MKLROOT/include/mkl_version.h)

echo "Your MKLROOT is now pointing to MKL version $MKL_VERSION:"
echo "    $MKLROOT"

if [ "$MKL_VERSION" != "$REQ_VERSION" ]; then
  echo "Error: MKL version $REQ_VERSION is required."
  exit 2
fi

echo -n "Copying relevant files... "
cp $MKLROOT/benchmarks/mp_linpack/* .
echo 'done!'
