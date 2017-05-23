#! /bin/sh
until who|grep "$1"  > /dev/null
do 
echo echo
done

echo -e \\a
echo "***** $1 has just logged in ******"
exit 0