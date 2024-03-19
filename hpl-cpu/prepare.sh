#!/bin/bash

cd $(dirname $0)

if grep -q GenuineIntel /proc/cpuinfo; then
  ./_prepare_intel.sh
else
  ./_prepare_amd.sh
fi
