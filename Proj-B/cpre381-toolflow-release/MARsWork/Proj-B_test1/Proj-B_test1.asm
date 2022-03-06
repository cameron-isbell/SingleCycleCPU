#
# Proj-B_test1 test program
#

# data section
.data

# code/instruction section
.text
addi  $1, $0, 1 			# Place “1” in $1
addi  $2, $0, 2				# Place “2” in $2
add   $3, $1, $2			# add $1 with $2, place it in $3
addiu $4, $3, 2		    	# add $3 with 2, place it in $4

and   $5, $3, $4			# and $3 with $4, place it in $5
andi  $6, $3, 1				# and $3 with 1, place it in $6

lui   $7, 210				# Load $7 with 210 shifted left 16 bit

addi  $20, $0, 0x10010000   # Place 1 in $20
sw    $7, 0($20)			# store $7 into addr of $20
lw    $8, 0($20)			# load value in addr $20 into $8
	
or    $9, $5, $6			# or $5 with $6, place it in $9
nor   $10, $5, $6			# nor $5 with $6, place it in $8
ori   $11, $5, 8			# ori $5 with 8, place it in $11
xor   $12, $5, $6			# xor $5 with $6, place it in $12
xori  $13, $5, 8			# xori $5 with 4, place it in $13

slt   $14, $2, $1			# checks $2<$1 (2<1) sets $14 to 0
slt   $15, $1, $2			# checks $1<$2 (1<2) sets $15 to 1
slti  $16, $1, 8			# checks $1<8 (1<8) sets $16 to 1

sll   $18, $1, 1			# shift left $1 (1) by 1
sllv  $19, $2, $1			# shift left $2 by $1 (1)
sra   $18, $2, 1			# shift right arithmetic $2 (2) by 1 -with sign
srl   $19, $2, 1			# shift right logical $2 (2) by 1 -without sign
srav  $18, $2, $2			# shift right arithmetic $2 (2) by $2 (2)
srlv  $19, $2, $2			# shift right logical $2 (2) by $2 (2)

addi  $2, $0, 10      		# Place "10" in $v0 to signal an "exit" or "halt"
syscall                		# Actually cause the halt