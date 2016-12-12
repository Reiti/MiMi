		.set noreorder
		.set noat

		.text
		.align  2
		.globl  _start
		.ent    _start
	                
_start:
		nop
		ori $1, $0, 0xAA
		nop
		nop
		sw $1,8($0)
		nop
		nop
		lw $2,8($0)
		nop
		nop


		.end _start
		.size _start, .-_start
