#安装模块 sudo insmod hello.ko
#卸载模块 sudo rmmod hello
#查看信息 dmesg|tail -n1
obj-m := hello.o

all: 
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=$(PWD) modules
clean:
	$(MAKE) -C /lib/modules/$(shell uname -r)/build M=$(PWD) clean