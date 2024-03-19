#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 Path_to_SSD"
  exit 1
fi

if [[ ! -d "$1" ]]; then
  echo "Error: '$1' is not a directory or does not exist."
  exit 2
fi

cd $(dirname $0)
cp ./fio ssd-test.fio $1
cd $1

./fio ssd-test.fio > fio.log

RESULT=$(echo $(awk '/bw=/ {print $2}' fio.log | sed 's/^bw=\(.*\)M.*/\1/g') | awk '{print 64*$1,64*$2,$3}' | tr ' ' ',')

echo Test,Hostname,Timestamp,ReadIOPS,WriteIOPS,WriteBW
echo IO-SSD,$(hostname),$(date '+%F %T'),$RESULT
