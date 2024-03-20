#!/bin/bash

FIO_VERSION=3.36

TAR_FILE="fio-$FIO_VERSION.tar.gz"
SOURCE="fio-$FIO_VERSION"

if [[ ! -f "$TAR_FILE" ]]; then
  echo Downloading FIO version $FIO_VERSION...
  wget -q https://brick.kernel.dk/snaps/fio-$FIO_VERSION.tar.gz
fi
echo "    $TAR_FILE" is ready.

if [[ ! -d "$SOURCE" ]]; then
  echo Extracting source files...
  tar -zxf $TAR_FILE
fi
echo "    $SOURCE/" is ready.

echo Compiling FIO...
cd $SOURCE
make
cd -

echo Installing FIO...
ln -sf $SOURCE/fio fio
echo "    ./fio" is ready.
