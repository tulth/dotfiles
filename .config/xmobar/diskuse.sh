#!/usr/bin/bash
set -e
rootuse=`df -Ph / | awk 'NR == 2{print $5}'`
homeuse=`df -Ph /home | awk 'NR == 2{print $5}'`
echo "root:$rootuse home:$homeuse"
