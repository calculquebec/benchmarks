#!/bin/bash

### Editable compilation options ###

CC=gcc
CFLAGS="-O3 -fopenmp -mcmodel=medium"

####################################

${CC} ${CFLAGS} \
  -DNTIMES=100 -DOFFSET=0 -DSTREAM_ARRAY_SIZE=8192000000 -DSTREAM_TYPE=double \
  stream.c -o stream.exe

