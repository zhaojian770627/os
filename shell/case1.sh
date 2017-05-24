#!/bin/sh

echo "Is ti morning?Please answer yes or no"
read timeofday

case "$timeofday" in
yes) echo "Good Moring";;
no) echo "Good Afternoon";;
y) echo "Good Morning";;
n) echo "Good Afternoon";;
*) echo "Sorry,answer not recognized";;
esac
exit 0
