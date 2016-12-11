        .set    noreorder
		.set	noat

        .text
        .align  2
        .globl  _start
        .ent    _start
                
_start:
		nop
		ori $2, $0, 1
		ori $3, $0, 2
		ori $4, $0, 6
		nop	
		nop
		add $7, $2, $3
		nop 
		nop
		bgez $7, 24
		nop
		nop
		nop
		nop
		add $5, $2, $3
		nop 
		nop
		addi $6, $5, -6
		nop
		nop
		bltz $6, -28
		nop
		nop
		nop
		nop

$loop:
        j               $loop
        nop

		.end	_start
		.size	_start, .-_start
