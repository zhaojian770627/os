BaseOfLoader		 equ	 09000h	; LOADER.BIN 被加载到的位置 ----  段地址
OffsetOfLoader	   	  equ	  0100h	; LOADER.BIN 被加载到的位置 ---- 偏移地址

BaseOfLoaderPhyAddr	   equ	BaseOfLoader*10h ; LOADER.BIN 被加载到的位置 ---- 物理地址

BaseOfKernelFile	   equ	 08000h	; KERNEL.BIN 被加载到的位置 ----  段地址
OffsetOfKernelFile 	   equ	     0h	; KERNEL.BIN 被加载到的位置 ---- 偏移地址

BaseOfKernelFilePhyAddr    equ	     BaseOfKernelFile*10h
KernelEntryPointPhyAddr	   equ	     030400h;必须与Makefile中参数-Ttext的值相等

PageDirBase		   equ	     200000h	; 页目录开始地址
PageTblBase		   equ	     201000h	; 页表开始地址 