#!/bin/sh
foo=1
while [ "$foo" -le 20 ]
do
echo "here we go again"
foo=$(($foo+1))
done
exit 0