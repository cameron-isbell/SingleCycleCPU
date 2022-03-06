#
# Proj-B_test3 test program
#

# data section
.data

# code/instruction section
.text

loopBranch:
sll 	$t0, $s2, 2
add 	$t1, $s0, $t0 			#address of base+j 
addi 	$t2, $t1, 4 			#address of base+(j+4)
lw 		$t3, 0($t1)
lw 		$t4 0($t2)
slt 	$t5, $t3, $t4
beq 	$t5, $zero, swap
j 		increment

swap:
sw 		$t4, 0($t1)
sw 		$t3, 0($t2)
j 		increment

increment:
addi 	$s2, $s2, 1
bne 	$s2, $s3, innerLoop
li 		$s2, 0
addi 	$s1, $s1, 1
beq 	$s1, $s3, exit
j 		loopBranch

endB:
addi  	$2, $0, 10      		# Place "10" in $v0 to signal an "exit" or "halt"
syscall 