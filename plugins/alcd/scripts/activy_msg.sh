#!/bin/sh
# Activy set Display text
/bin/stty 38400 < /dev/ttyS0
printf "\x9A\x02$1\x00" > /dev/ttyS0
printf "\x9A\x03$2\x00" > /dev/ttyS0
printf "\xF0\x3D" > /dev/ttyS0

