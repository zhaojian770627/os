	# 将输入文件的所有字母转换为大写字母
	.section .data

	# 系统调用号
	.equ	SYS_OPEN,5
	.equ 	SYS_WRITE,4
	.equ 	SYS_READ,3
	.equ 	SYS_CLOSE,6
	.equ	SYS_EXIT,1

	# 文件打开选项
	.equ	O_RDONLY,0
	.equ	O_CREAT_WRONLY_TRUNC,03101

	# 标准文件描述符
	.equ	STDIN,0
	.equ	STDOUT,1
	.equ	STDERR,2

	# 系统调用中断
	.equ	LINUX_SYSCALL,0x80
	.equ	END_OF_FILE,0
	.equ	NUMBER_ARGUMENTS,2

	.section .bss
	# 缓冲区
	.equ	BUFFER_SIZE,500
	.lcomm BUFFER_DATA,BUFFER_SIZE

	.section .text

	# 栈位置
	.equ	ST_SIZE_RESERVE,8
	.equ	ST_FD_IN,-4
	.equ	ST_FD_OUT,-8	
	.equ	ST_ARGC,0
	.equ	ST_ARGV_0,4
	.equ	ST_ARGV_1,8
	.equ	ST_ARGV_2,12

	.globl _start
_start:
	movl	%esp,%ebp

	subl	$ST_SIZE_RESERVE,%esp

open_files:
open_fd_in:
	#打开输入文件
	movl	$SYS_OPEN,%eax
	#将输入文件放入 '%ebx'
	movl	ST_ARGV_1(%ebp),%ebx
	#只读标志
	movl	$O_RDONLY,%ecx
	movl	$0666,%edx
	# 系统调用
	int	$LINUX_SYSCALL
store_fd_in:
	movl	%eax,ST_FD_IN(%ebp)

open_fd_out:
	# 打开输出文件
	mov	$SYS_OPEN,%eax
	# 将输出文件名放入%ebx
	movl	ST_ARGV_2(%ebp),%ebx
	#写入文件标志
	movl	$O_CREAT_WRONLY_TRUNC,%ecx
	# 新文件模式
	movl	$0666,%edx
	# Call Linux
	int	$LINUX_SYSCALL
store_fd_out:
	# 这里存储文件描述符
	movl	%eax,ST_FD_OUT(%ebp)

	###主循环开始####
read_loop_begin:
	movl	$SYS_READ,%eax
	# 获取输入文件描述符
	movl	ST_FD_IN(%ebp),%ebx
	# 放置读取数据的存储位置
	movl	$BUFFER_DATA,%ecx
	# 缓冲区大小
	movl	$BUFFER_SIZE,%edx
	# 读取缓冲区大小返回到%eax中
	int	$LINUX_SYSCALL

	## 如到达文件结束处就退出
	cmpl	$END_OF_FILE,%eax
	# 如果发现文件结束符或出现错误，就跳转到程序结束处
	jle	end_loop
continue_read_loop:
	pushl	$BUFFER_DATA	#缓冲区位置
	pushl	%eax		#缓冲区大小
	call	convert_to_upper
	popl	%eax		#重新获取大小
	addl	$4,%esp		#恢复%esp

	## 将字符块写入输出文件 ###
	# 缓冲区大小
	movl	%eax,%edx
	movl	$SYS_WRITE,%eax
	# 要使用的文件
	movl	ST_FD_OUT(%ebp),%ebx
	# 缓冲区位置
	movl	$BUFFER_DATA,%ecx
	int	$LINUX_SYSCALL

	###循环继续###
	jmp	read_loop_begin
end_loop:
	###关闭文件###
	movl	$SYS_CLOSE,%eax
	movl	ST_FD_OUT(%ebp),%ebx
	int	$LINUX_SYSCALL

	movl	$SYS_CLOSE,%eax
	movl	ST_FD_IN(%ebp),%ebx
	int	$LINUX_SYSCALL

	### 退出 ###
	movl	$SYS_EXIT,%eax
	movl	$0,%ebx
	int	$LINUX_SYSCALL

	###-------------------------------------
	## 将字符块内容转换为大写形式
	###-------------------------------------
	# %eax-缓冲去起始地址
	# %ebx-缓冲区长度
	# %edi-当前缓冲区偏移量
	# %cl -当前正在检测的字节

	### 常数 ###
	# 我们搜索的下边界
	.equ	LOWERCASE_A,'a'
	# 我们搜索的上边界
	.equ	LOWERCASE_Z,'z'
	# 大小写转换
	.equ	UPPER_CONVERSION,'A' - 'a'

	### 栈相关信息 ###
	.equ	ST_BUFFER_LEN,8	# 缓冲区长度
	.equ	ST_BUFFER,12	# 实际缓冲区
convert_to_upper:
	pushl	%ebp
	movl	%esp,%ebp

	### 设置变量 ###
	movl	ST_BUFFER(%ebp),%eax
	movl	ST_BUFFER_LEN(%ebp),%ebx
	mov	$0,%edi

	cmpl	$0,%ebx
	je	end_convert_loop

convert_loop:
	# 获取当前字节
	movb	(%eax,%edi,1),%cl

	# 除非该字节在'a'和'z'之间，否则读取下一个字节
	cmpb	$LOWERCASE_A,%cl
	jl	next_byte
	cmpb	$LOWERCASE_Z,%cl
	jg	next_byte

	# 转换为大写字母
	addb	$UPPER_CONVERSION,%cl
	# 存回原处
	movb	%cl,(%eax,%edi,1)
next_byte:	
	incl	%edi		# 下个字节
	cmpl	%edi,%ebx
	jne	convert_loop
end_convert_loop:
	# 无返回值，离开程序即可
	movl	%ebp,%esp
	popl	%ebp
	ret
	