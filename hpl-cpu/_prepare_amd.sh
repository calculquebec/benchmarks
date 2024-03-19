#!/bin/bash

BLIS_VERSION=2.2-4
AOCC_VERSION=2.2.0

BLIS_FILE="aocl-blis-linux-aocc-${BLIS_VERSION}.tar.gz"
HPL_FILE="aocl-hpl-blis-mt-aocc-${BLIS_VERSION}.tar.gz"
AOCC_FILE="aocc-compiler-${AOCC_VERSION}.tar"

function missing_tar {
  echo "Error: Missing archive file $1."
  echo
  echo "* $BLIS_FILE can be downloaded from:"
  echo "    https://github.com/amd/blis/releases/download/${BLIS_VERSION:0:3}/$BLIS_FILE"
  echo "* $HPL_FILE can be downloaded from:"
  echo "    https://developer.amd.com/amd-aocl/blas-library/"
  echo "* $AOCC_FILE can be downloaded from:"
  echo "    https://developer.amd.com/amd-aocc/"

  exit
}

if [ ! -f $BLIS_FILE ]; then  missing_tar $BLIS_FILE; fi
if [ ! -f  $HPL_FILE ]; then  missing_tar  $HPL_FILE; fi
if [ ! -f $AOCC_FILE ]; then  missing_tar $AOCC_FILE; fi

echo "Extracting AMD BLIS and OpenMP files..."
tar -zxf $BLIS_FILE
tar -zxf  $HPL_FILE
tar -xf  $AOCC_FILE aocc-compiler-${AOCC_VERSION}/lib/libomp.so

echo "Completing installation..."
ln -sf libomp.so aocc-compiler-${AOCC_VERSION}/lib/libomp.so.5

# Calcul Quebec specifics
if [ -x "$(command -v patchelf)" ]; then
    OPENMPI=/cvmfs/soft.computecanada.ca/easybuild/software/2020/avx2/Compiler/gcc9/openmpi/4.0.3
    if [ -d $OPENMPI ]; then
        patchelf --set-rpath $OPENMPI/lib amd-hpl-blis-aocc/xhpl
    fi
    EPREFIX=/cvmfs/soft.computecanada.ca/gentoo/2020
    if [ -d $EPREFIX ]; then
        patchelf --set-interpreter $EPREFIX/lib/ld-linux-x86-64.so.2 amd-hpl-blis-aocc/xhpl
    fi
fi

cp HPL_AMD.dat HPL.dat
echo 'Done!'
