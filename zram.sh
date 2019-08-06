#!/bin/bash
#This script will allow the use of all 4 cores and set aside 1.5GB for zram
modprobe zram num_devices=4

totalmem=`free | grep -e "^Mem:" | awk '{print $2}'`
mem=$(( ($totalmem)* 512))

echo $mem > /sys/block/zram0/disksize
echo $mem > /sys/block/zram1/disksize
echo $mem > /sys/block/zram2/disksize
echo $mem > /sys/block/zram3/disksize

mkswap /dev/zram0
mkswap /dev/zram1
mkswap /dev/zram2
mkswap /dev/zram3

swapon -p 5 /dev/zram0
swapon -p 5 /dev/zram1
swapon -p 5 /dev/zram2
swapon -p 5 /dev/zram3

