#!/bin/bash

# set a warning threshold
maxuse=20

# extract disk info and create a threshold variable for awk
df -h | awk -v mu=$maxuse '

# get all the disk columns, omit header
NR>1{ 

# define the usage column, force numeric conversion
usage = $5 + 0

# create condition for the  warning and print the warning message respectively
if  (usage >= mu) {
print  "WARNING! " $1 " is " $5 " full"

# set a flag for the warning/threshold met
found=1}}

#  exit  awk with exit code 1 if warning happened, 0 otherwise
END {exit found}'
