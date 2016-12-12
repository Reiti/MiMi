		.set noreorder
		.set noat

		.text
		.align  2
		.globl  _start
		.ent    _start
	                
_start:
		nop
		ori $1, $0, 0xAA
		ori $2, $0, 0x55
		nop
		nop
		sw $1,8($0)
		sw $2,12($0)
		nop
		nop
		lw $3, 8($0)
		lw $4, 12($0)
		nop
		nop


		.end _start
		.size _start, .-_start
