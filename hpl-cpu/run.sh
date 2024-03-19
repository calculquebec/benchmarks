#!/bin/sh

cd $(dirname $0)

if grep -q GenuineIntel /proc/cpuinfo; then
  ./_run_intel.sh
else
  ./_run_amd.sh
fi

PASSED=$(grep -E '_oo/' hpl.log | awk '{print $4}')
RESULT=$(grep -A 2 -E 'Time *Gflops' hpl.log | tail -n 1 | awk '{print $(NF-5)","$(NF-4)","$(NF-3)","$(NF-2)","$(NF-1)","$NF}')

echo Test,Hostname,Timestamp,ResidualCheck,N,NB,P,Q,ElapsedTime,Gflops
echo HPL-CPU,$(hostname),$(date '+%F %T'),$PASSED,$RESULT
