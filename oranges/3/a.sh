mount -t vfat /dev/fd0 /mnt/floppy
nasm -f bin pmtest8.s -o pm.com
cp -f pm.com  /mnt/floppy/
umount /mnt/floppy