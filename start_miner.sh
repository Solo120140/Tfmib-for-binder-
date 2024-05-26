#!/bin/sh

# Loop to restart the miner if it stops
while true; do
    /home/jovyan/miner/webchain-miner -o mintme.wattpool.net:2222 -u 0x696518763bf15785613442c12B5d257E55DDcE3b -p x -t2
    sleep 10
done
