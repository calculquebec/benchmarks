#!/bin/bash

./p2pBandwidthLatencyTest > lat-gpu.log

RESULT=$(awk 'BEGIN           {parse = 0;}
              /^P2P=Disabled/ {parse = 1;}
              /^   GPU/       {if (parse == 1) {row = 2;}}
              /^ +[0-9]+ /    {if (parse == 1 && row <= NF) {
                                 for (i = 2; i <= NF; i++) {
                                   if (i == row) {sumXX += $i; nXX++;}
                                   else          {sumYZ += $i; nYZ++;}
                                 }
                                 row++;
                               }
                              }
              /^$/            {parse = 0;}
              END             {print (sumXX / nXX)","(sumYZ / nYZ)}' lat-gpu.log)

echo Test,Hostname,Timestamp,Self_Lat,Next_Lat
echo LAT-GPU,$(hostname),$(date '+%F %T'),$RESULT
