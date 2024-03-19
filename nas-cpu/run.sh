#!/bin/bash

for i in $(cat suite.def | awk '{print $1"."$2}'); do
  TEST=NPB3.4.1/NPB3.4-OMP/bin/${i}.x; 
  echo Running $TEST >&2
  $TEST
done | awk '/Completed/     {test=$1}
            /Mop\/s total/  {mops=$4}
            /=.*SUCCESSFUL/ {print test","mops}' > mops_total.csv

RESULT=$(python normalize.py mops_total.csv mops_ref.csv)

echo Test,Hostname,Timestamp,AverageScore
echo NAS-CPU,$(hostname),$(date '+%F %T'),$RESULT
