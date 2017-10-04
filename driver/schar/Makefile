#安装模块 sudo insmod schar.ko
#卸载模块 sudo rmmod schar
#查看信息 dmesg|tail -n1
obj-m := schar.o

all: 
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules
clean:
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean