#
# Proj-C_test1 test program	
#

# data section
.data

# code/instruction section
.text

# Instructions supported by pipeline to be tested:
# add, addi, noop = add $0, $0, $0, addiu, and, andi, lui, sw, lw, or,
# nor, ori, xor, xori, slt, slti, sll, srl, srav, srlv, beq, bne, j

addi  	$1, $0, 1 			# Place “1” in $1
addi  	$2, $0, 2			# Place “2” in $2

add     $0, $0, $0			#NOP
add     $0, $0, $0			#NOP
add     $0, $0, $0			#NOP

add   	$3, $1, $2			# add $1 with $2, place it in $3
addiu	$4, $1, 2			# add $1 with 2, place in $4

add     $0, $0, $0			#NOP
add     $0, $0, $0			#NOP

and 	$5, $3, $2			# and $3 with $2, place it in $5
andi	$6, $3, 1			# and $3 with 1, place in $6

lui		$7, 2				# Load $7 with 2 shifted 16 bit

addi  $20, $0, 0xFFFF0000   # Setup address for $20

add     $0, $0, $0			#NOP
add     $0, $0, $0			#NOP
add     $0, $0, $0			#NOP

sw    $7, 0($20)			# store $7 into addr of $20
lw    $8, 0($20)			# load value in addr $20 into $8

or    $9, $5, $6			# or $5 with $6, place it in $9
nor   $10, $5, $6			# nor $5 with $6, place it in $8
ori   $11, $5, 8			# ori $5 with 8, place it in $11
xor   $12, $5, $6			# xor $5 with $6, place it in $12
xori  $13, $5, 8			# xori $5 with 4, place it in $13

beq   $9, $10, endB			# Branch to endB if $9 and $10 equal (shouldn't)

bne   $9, $10, extraB		# Branch to extraB if $9 and $10 not equal (should)

resBr:
addi  $1, $0, 1 			# Place “1” in $1
addi  $2, $0, 2				# Place “2” in $2

add     $0, $0, $0			#NOP
add     $0, $0, $0			#NOP
add     $0, $0, $0			#NOP

slt   $14, $2, $1			# checks $2<$1 (2<1) sets $14 to 0
slt   $15, $1, $2			# checks $1<$2 (1<2) sets $15 to 1
slti  $16, $1, 8			# checks $1<8 (1<8) sets $16 to 1

j     shiftB				# jump to shift branch
							# Wait to read
add     $0, $0, $0			# NOP

endB:
addi  $2, $0, 10      		# Place "10" in $v0 to signal an "exit" or "halt"
syscall                		# Actually cause the halt

extraB:
addi  $3, $0, 4				# set $3 to 4
addi  $4, $0, 4				# set $4 to 4

add     $0, $0, $0			#NOP
add     $0, $0, $0			#NOP
add     $0, $0, $0			#NOP

beq   $3, $4, resBr			# branch if #3 and $4 equal (should)
							# Wait to read
add     $0, $0, $0			# NOP
j	  endB					# branch to end (should't get to this)
							# Wait to read
add     $0, $0, $0			# NOP

shiftB:
sll   $18, $1, 1			# shift left $1 (1) by 1
srl   $19, $2, 1			# shift right logical $2 (2) by 1 -without sign
srav  $18, $2, $2			# shift right arithmetic $2 (2) by $2 (2)
srlv  $19, $2, $2			# shift right logical $2 (2) by $2 (2)
j     endB					# jump to the end of the program
							# Wait to read
add     $0, $0, $0			# NOP