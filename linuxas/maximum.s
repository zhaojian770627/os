# 目的:寻找最大值
# 变量:
#	%edi-正在被检测的数据项索引
#	%ebx-当前已经找到的最大整数项
#	%eax-当前数据项
#
# 使用以下内存位置
# data_items-包含数据项
#		0表示数据结束
#
	.section .data
data_items:	#这些都是数据项
	.long 3,67,34,222,45,75,54,34,44,33,22,11,66,0

	.section .text
	.globl	_start

_start:
	movl	$0,%edi
	movl	data_items(,%edi,4),%eax
	movl	%eax,%ebx

start_loop:
	cmpl	$0,%eax
	je	loop_exit
	incl	%edi
	mov	data_items(,%edi,4),%eax
	cmpl	%ebx,%eax
	jle	start_loop
	movl	%eax,%ebx
	jmp	start_loop
loop_exit:
	movl	$1,%eax
	int	$0x80
	