# board3.s ... Game of Life on a 5x5 grid

	.data

N:	.word 5  # gives board dimensions

board:
	.byte 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1
	.byte 1, 1, 1, 1, 1





newBoard: .space 25
