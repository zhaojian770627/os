# 目的:退出并向Linux内核返回一个状态码的简单程序
# 输入:无
# 输出:返回一个状态码。在运行程序后可通过输入echo $?来读取状态码
# 变量:
# 	%eax保存系统调用号
# 	%ebx保存返回状态
	.section .text
	.globl _start
_start:
	movl	$1,%eax
	movl	$0,%ebx
	int	$0x80
	