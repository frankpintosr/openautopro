#!/bin/bash
# This script enables zram, an in-kernel compressed cache for swap pages.  https://en.wikipedia.org/wiki/Zram
# The script will set aside 384MB per core for zram and specifies the LZ4 compression algorithm

modprobe zram num_devices=4

echo '384M' > /sys/block/zram0/disksize
echo '384M' > /sys/block/zram1/disksize
echo '384M' > /sys/block/zram2/disksize
echo '384M' > /sys/block/zram3/disksize

echo 'lz4' > /sys/block/zram0/comp_algorithm
echo 'lz4' > /sys/block/zram1/comp_algorithm
echo 'lz4' > /sys/block/zram2/comp_algorithm
echo 'lz4' > /sys/block/zram3/comp_algorithm

mkswap /dev/zram0
mkswap /dev/zram1
mkswap /dev/zram2
mkswap /dev/zram3

swapon -p 5 /dev/zram0
swapon -p 5 /dev/zram1
swapon -p 5 /dev/zram2
swapon -p 5 /dev/zram3

