#!/bin/bash

./bandwidthTest --csv --device=all --memory=pinned --mode=shmoo > bw-gpu.log

CHECK=$(grep 'Result =' bw-gpu.log | cut -d' ' -f3)
BW_H2D=$(grep Test-H2D bw-gpu.log | tail -1 | awk '{print $4}')
BW_D2H=$(grep Test-D2H bw-gpu.log | tail -1 | awk '{print $4}')
BW_D2D=$(grep Test-D2D bw-gpu.log | tail -1 | awk '{print $4}')

echo Test,Hostname,Timestamp,Check,BW_H2D,BW_D2H,BW_D2D
echo BW-GPU,$(hostname),$(date '+%F %T'),$CHECK,$BW_H2D,$BW_D2H,$BW_D2D
