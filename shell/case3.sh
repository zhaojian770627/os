#!/bin/sh

echo "Is ti morning?Please answer yes or no"
read timeofday

case "$timeofday" in
yes|y|Yes|YES)
 echo "Good Moring"
 echo "Up bright and early this morning"
 ;;
[nN]*) echo "Good Afternoon"
 ;;
*) echo "Sorry,answer not recognized"
 ;;
esac
exit 0
