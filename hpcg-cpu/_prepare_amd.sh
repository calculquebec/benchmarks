#!/bin/bash

HPCG_VERSION=2022_11

HPCG_FILE="amd-zen-hpcg-${HPCG_VERSION}.tar.gz"

function missing_tar {
  echo "Error: Missing archive file $1."
  echo
  echo "* $HPCG_FILE can be downloaded from:"
  echo "    https://www.amd.com/en/developer/zen-software-studio/applications/pre-built-applications.html"

  exit
}

if [ ! -f  $HPCG_FILE ]; then  missing_tar  $HPCG_FILE; fi

echo "Extracting HPCG files..."
tar -zxf  $HPCG_FILE

echo "Completing installation..."

echo 'Done!'
