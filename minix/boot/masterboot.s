	LOADOFF	   =	0x7C00	# 0x0000:LOADOFF is where this code is loaded
	BUFFER	   =	0x0600	# First free memory
	PART_TABLE =	   446	# Location of partition table within this code
	PENTRYSIZE =	    16	# Size of one partition table entry
	MAGIC	   =	   510	# Location of the AA55 magic number


	bootind	   =	     0
	sysind	   =	     4
	lowsec	   =	     8
master:
	xor	ax, ax
	mov	ds, ax
	mov	es, ax
	cli
	mov	ss, ax			! ds = es = ss = Vector segment
	mov	sp, #LOADOFF
	sti
	