#! /bin/sh

# first.sh

for file in *
do
    if grep -q file $file
    then
	more $file
    fi
done
exit 0