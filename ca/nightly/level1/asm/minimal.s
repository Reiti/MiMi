		.set noreorder
		.set noat

		.text
		.align  2
		.globl  _start
		.ent    _start
	                
_start:
		nop
		ori $1, $0, 0xAA
		ori $2, $0, 0xBB
		ori $3, $0, 0xCC
		addi $4, $1, 0xAA00
		sh $2,4($0)
		nop
		nop
		beq $1, $4, $t
		nop	
		nop		
		nop
		lh $5,4($0)
$t:
		j $end
		nop
		nop
		or $6, $2, $3
		or $7, $2, $3
$end:
		
		bgez $1, $end
		nop	
		nop		
		nop
		or $8, $2, $3

		.end _start
		.size _start, .-_start
















































