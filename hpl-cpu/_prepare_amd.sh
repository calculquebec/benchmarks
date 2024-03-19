#!/bin/bash

HPL_VERSION=2023_07_18

HPL_FILE="amd-zen-hpl-${HPL_VERSION}.tar.gz"

function missing_tar {
  echo "Error: Missing archive file $1."
  echo
  echo "* $HPL_FILE can be downloaded from:"
  echo "    https://www.amd.com/en/developer/zen-software-studio/applications/pre-built-applications.html"

  exit
}

if [ ! -f  $HPL_FILE ]; then  missing_tar  $HPL_FILE; fi

echo "Extracting HPL files..."
tar -zxf  $HPL_FILE

echo "Completing installation..."

# Calcul Quebec specifics
if [ -x "$(command -v patchelf)" ]; then
    OPENMPI=/cvmfs/soft.computecanada.ca/easybuild/software/2023/x86-64-v3/Compiler/gcc12/openmpi/4.1.5
    if [ -d $OPENMPI ]; then
        patchelf --set-rpath $OPENMPI/lib amd-zen-hpl-${HPL_VERSION}/xhpl
    fi
    EPREFIX=/cvmfs/soft.computecanada.ca/gentoo/2023/x86-64-v3
    if [ -d $EPREFIX ]; then
        patchelf --set-interpreter $EPREFIX/lib64/ld-linux-x86-64.so.2 amd-zen-hpl-${HPL_VERSION}/xhpl
    fi
fi

echo 'Done!'
