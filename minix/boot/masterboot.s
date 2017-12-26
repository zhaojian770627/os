	LOADOFF	   equ	0x7C00	;0x0000:LOADOFF is where this code is loaded 
	BUFFER	   equ	0x0600	;First free memory 
	PART_TABLE equ	   446	;Location of partition table within this code
	PENTRYSIZE equ	    16	;Size of one partition table entry
	MAGIC	   equ	   510	;Location of the AA55 magic number


	bootind	   equ	     0
	sysind	   equ	     4
	lowsec	   equ	     8
[section .text]
master:
	xor	ax, ax
	mov	ds, ax
	mov	es, ax
	cli
	mov	ss, ax			;ds = es = ss = Vector segment
	mov	sp, LOADOFF
	sti
	;; Copy this code to safety, then jump to it.
	