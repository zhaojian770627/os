#
all:os.img
os.img:pm.com
	cp ~/imgs/freedos.img ~/imgs/os.img
	#sudo umount /mnt/floppy
	sudo mount -o loop ~/imgs/os.img /mnt/floppy
	sudo cp pm.com /mnt/floppy
pm.com:
	nasm -f bin pmtest9.s -o pm.com
clean:
	$(RM) *.img *.bin *.sys *.o *.com  *.lst *.txt
