
# board2.s ... Game of Life on a 15x15 grid

	.data

N:	.word 15  # gives board dimensions

board:
	.byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0
	.byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
	.byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
	.byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0
	.byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0

newBoard: .space 225

# COMP1521 19t2 ... Game of Life on a NxN grid
#
# Written by <<YOU>>, June 2019

## Requires (from `boardX.s'):
# - N (word): board dimensions
# - board (byte[][]): initial board state
# - newBoard (byte[][]): next board state

# Provides:


########################################################################
	
	.data
	.align 2
message1:	.asciiz "# Iterations: "
message2:	.asciiz "=== After iteration "
message3:	.asciiz " ===\n"
next_line:  .asciiz "\n"
alive:	.asciiz "#"
deaded:	.asciiz "."
nn:		.word 0
byte_1:	.byte 1
byte_0:	.byte 0

	.align 2
main_return:	.space 4
decideCell_return:	.space 4
neighbours_return:	.space 4
copyBackAndShow_return:	.space 4


	.text
.globl	main
main:
	sw    $ra, main_return
	# printf("# Iterations: ");
	la    $a0, message1
	li    $v0, 4
	syscall
	# scan and store maxiters to $t0
	li	  $v0, 5
	syscall
	move  $t0, $v0
	# set up values
	li    $s0, 0		# row i
	li    $s1, 0		# col j
	li    $s2, 0		# curr iter
	move  $s3, $t0		# maxiters
	lw	  $s4, N 		# dim
	li 	  $s5, 0		# index for array
# for (iter < maxiter)
iterloop:
	beq	  $s2, $s3, main__post
# for (row < N)
rowloop:
	beq	  $s0, $s4, end_rowloop
	li    $s1, 0
# for (col < N)
colloop:
	beq	  $s1, $s4, end_colloop
	# jump to neighbours function to get the num
	jal	  neighbours
	# jump to decidecell function to decide cell
	jal   decideCell
	addi  $s5,$s5, 1
	addi  $s1,$s1, 1
	j     colloop
end_rowloop:
	# outter loop add 1
	addi  $s2, $s2, 1
	# printf("=== After iteration ")
	la    $a0, message2 
    li    $v0, 4
    syscall
    # printf(%d)
    move  $a0, $s2
    li    $v0, 1
    syscall
    # printf(" ===")
    la    $a0, message3
    li    $v0, 4
    syscall
	# show last iteration
	jal	  copyBackAndShow
	#reset
	li   $s0, 0
	li   $s1, 0
	li   $s5, 0
	# go next iteration
	j     iterloop
end_colloop:
	addi  $s0, $s0, 1
	j     rowloop
main__post:
	lw	$ra, main_return
	jr	$ra






#################################
# return the num of neighbours/nn
.globl	neighbours
neighbours:
	sw  $ra, neighbours_return
	# x,y dirction
	li  $s6, -1
	li  $s7, -1
	# dim N
	lw	$a1, N
	# N - 1
	addi	$a1, $a1, -1
	# <= 1
	li  $a2, 2
	# set nn = 0
	li   $t0, 0
	sw   $t0, nn
# x direction loop
x_loop:
	# x <= 1
	beq  $s6, $a2, end_x_loop
# y direction loop
y_loop:
	# y <= 1
	beq	 $s7, $a2, end_y_loop
	# at edge skip
	li   $t1, 0
	add  $t1, $s0, $s6
	bltz $t1, continue
	bgt	 $t1, $a1, continue
	li   $t1, 0
	add  $t1, $s1, $s7
	bltz $t1, continue
	bgt	 $t1, $a1, continue
	# not itslef go check
	li   $t1,0
	bne	 $s6, $t1, check
	bne  $s7, $t1, check
	j    continue
check:
	lb   $t2, byte_1
	# row major formula: cell index = x * N + y + index
	lw	 $t3, N
	mul	 $t4, $s6, $t3
	add  $t4, $t4, $s7
	add  $t5, $s5, $t4
	lb	 $t6, board($t5)
	# board[i][j] == 0 continue
	bne	 $t2, $t6, continue
	# else nn++ 
	lw	 $a3, nn
	addi $a3, $a3, 1
	# store nn value to the data segment
	sw   $a3, nn
	j    continue
# continue check y_loop
continue:
	addi $s7, $s7, 1
	j    y_loop
# jump to next x_loop
end_y_loop:
	addi $s6, $s6, 1
	li   $s7, -1
	j    x_loop
# return nn
end_x_loop:
	lw	$ra, neighbours_return
	jr  $ra






###############################
.globl	decideCell
decideCell:
	sw    $ra, decideCell_return
	lb	  $t7, board($s5)
	lb	  $t0, byte_1
	# if cell == 1 means living
	beq   $t7, $t0, living
	# else dead
	j  	  dead
# board[i][j] == 0
dead:
	li 	  $t0, 3
	lw 	  $t1, nn
	# if (nn == 3) resurgence
	beq   $t1, $t0, resurgence
	# else truly dead
	j     end_decideCell
# board[i][j] == 1
living:
	li   $t0, 2
	lw   $t1, nn
	beq  $t1, $t0, resurgence
	li   $t0, 3
	beq  $t1, $t0, resurgence
	j    kill
# if (nn == 2 || 3)
resurgence:
	lb   $t0, byte_1
	sb   $t0, newBoard($s5)
	j    end_decideCell
# live but its neighbours less than 2 or bigger than 3
kill:
	lb	 $t0, byte_0
	sb   $t0, newBoard($s5)
	j    end_decideCell
end_decideCell:
	lw   $ra, decideCell_return
	jr   $ra





###############################
.globl	copyBackAndShow
copyBackAndShow:
	sw	$s0, -4($sp)	
	sw	$s1, -8($sp)	
	sw	$s5, -12($sp)	
	addi	$sp, $sp, -12
	sw   $ra, copyBackAndShow_return
	# reset
	li   $s0, 0
	li   $s1, 0
	li   $s5, 0
# row iter
row:
	beq  $s0, $s4, end_row
	li   $s1, 0
#col iter
col:
	beq  $s1, $s4, end_col
	lb	 $t1, newBoard($s5)
	sb   $t1, board($s5)
	lb   $t0, byte_1
	beq  $t1, $t0, print_alive
# .
print_dead:
	lb   $a0, deaded
	li   $v0, 11
	syscall
	j    continue_show
# #
print_alive:
	lb   $a0, alive
	li   $v0, 11
	syscall
	j    continue_show
continue_show:
	addi $s5, $s5, 1
	addi $s1, $s1, 1
	j 	 col
end_col:
	# print newline
	la   $a0, next_line
	li   $v0, 4
	syscall
	# jump to next row
	addi $s0, $s0, 1
	j 	 row
# end of rows
end_row:
	lw	$s5, -12($sp)	
	lw	$s1, -8($sp)	
	lw	$s0, -4($sp)
    addi	$sp, $sp, 12	
	lw   $ra, copyBackAndShow_return
	jr   $ra



