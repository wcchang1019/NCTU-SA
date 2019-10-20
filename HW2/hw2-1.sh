#!/bin/sh
ls -lAR | grep ^[-d] | sort -rn -k5 | awk 'BEGIN {count=1;fileNum=0;dirNum=0;fileSize=0;} {if(count < 6 && $1 ~ /^-/){print count":"$5 " " $9;count++} }$1 ~ /^d/ {dirNum++;} $1 ~ /^-/ {fileNum++;fileSize += $5} END {print "Dir num: "dirNum "\nFile num: "fileNum "\nTotal: "fileSize}'
