#!/bin/bash

COMPUTE_CAPABILITIES="70 75 80"
CUDA_VERSION=11.0

TAR_FILE="../cuda-samples-$CUDA_VERSION.tar.gz"
SOURCE="../cuda-samples-$CUDA_VERSION"
TEST=bandwidthTest

if [[ ! -f "$TAR_FILE" ]]; then
  echo Downloading CUDA Samples version $CUDA_VERSION...
  wget -q https://github.com/NVIDIA/cuda-samples/archive/v$CUDA_VERSION.tar.gz -O $TAR_FILE
fi
echo "    $TAR_FILE" is ready.

if [[ ! -d "$SOURCE" ]]; then
   echo Extracting source files...
   tar -zxf $TAR_FILE --directory ../
fi
echo "    $SOURCE/" is ready.

echo Compiling $TEST...
cd $SOURCE/Samples/$TEST
make SMS="$COMPUTE_CAPABILITIES"
cd -

echo Installing $TEST...
ln -sf $SOURCE/bin/x86_64/linux/release/$TEST $TEST
echo "    ./$TEST" is ready.
