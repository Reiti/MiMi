        .set    noreorder
		.set	noat

        .text
        .align  2
        .globl  _start
        .ent    _start
               
_start:
		nop
		addi $2, $0, $test
		ori $3, $0, $test2
		nop
		nop
		jalr $3, $2	
$test2:	nop
		nop		
		nop
		nop	
		ori $4, $0, 1
		ori $4, $0, 2
		nop
$loop:
        j               $loop
        nop
		nop
		nop
		nop
$test:
	ori $5, $0, 1
	jr $3
		nop
	



		.end	_start
		.size	_start, .-_start
