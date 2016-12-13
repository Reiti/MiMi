        .set    noreorder
		.set	noat

        .text
        .align  2
        .globl  _start
        .ent    _start
               
_start:
	# store them numbers
	#.word 8, 4, 5, 16, 9, 3, 10, 0, 1, 6
	ori $1, 8
	ori $2, 4
	ori $3, 5
	ori $4, 16
	ori $5, 9
	ori $6, 3
	ori $7, 10
	ori $8, 0
	ori $9, 1
	ori $10, 6
	sw $0, 4($0)
	sw $1, 8($0)
	sw $2, 12($0)
	sw $3, 16($0)
	sw $4, 20($0)
	sw $5, 24($0)
	sw $6, 28($0)
	sw $7, 32($0)
	sw $8, 36($0)
	sw $9, 40($0)
	sw $10, 44($0)

	xor $2, $2, $2
	xor $1, $1, $1
	xor $9, $9, $9
	ori $9, 9 #number of numbers - 1
	ori $2, 4 # address of nums
loop:
	xor $7, $7, $7 # inner counter
	xor $5, $5, $5 # list sorted bool
	nop
in_loop:
	sll $16, $7, 2
	nop
	nop
	add $1, $2, $16 # current elements memory address
	nop
	nop
	lw $11, 0($1)
	lw $12, 4($1)
	nop
	nop
	sub $13, $11, $12
	nop
	nop
	blez $13, no_op
	# swap
	sw $11, 4($1)
	sw $12, 0($1)
	ori $5, 1
no_op:

	addi $7, 1
	nop
	nop
	bne $7, $9, in_loop
	nop
	nop
	nop
	
	bgtz $5, loop
	nop
	nop
	nop

	lw $0, 4($0)
	lw $1, 8($0)
	lw $2, 12($0)
	lw $3, 16($0)
	lw $4, 20($0)
	lw $5, 24($0)
	lw $6, 28($0)
	lw $7, 32($0)
	lw $8, 36($0)
	lw $9, 40($0)
	lw $10, 44($0)

done:
	j done
	nop
	nop
	nop
	.size	_start, .-_start

	.data
	.word 0 # null address
nums:	.word 8, 4, 5, 16, 9, 3, 10, 0, 1, 6
	



