#!/bin/sh

# Loop to restart the miner if it stops
while true; do
    /home/jovyan/miner/webchain-miner -o mintme.wattpool.net:2222 -u mywalletaddress -p x -t2
    sleep 10
done