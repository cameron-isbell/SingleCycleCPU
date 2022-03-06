#
# Proj-C_test1 test program	
#

# data section
.data
arr:    .word 8, 4, 7, 4, 2
size:   .word 5 	                #size has to be 1 smaller for the loop

# code/instruction section
.text
.globl main

# Bubblesort avoids control plus data hazards:

main:
lui     $at, 0x00001001				# First half of la
addi    $s1, $0, 0     			    # i, set up the i var
addi    $s2, $0, 0     			    # j, set up the j var
									# Stall for $at
add     $0, $0, $0					#NOP

ori     $s0, $at, 0x00000018       	# second half of la, addr of size n
									# Stall for $s0
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP

lw		$s0, 0($s0)					# n, set up the n var
									# Stall for $s0
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP

lui     $at, 0x00001001				# First half of la, again
sub     $s3, $s0, $s1   			# m = n-i-1
sll     $s6, $s0, 2    			 	# Byte addressing n
ori     $a0, $at, 0x00000000		# Second half of la, addr of array
									# Stall for $s3
add     $0, $0, $0					# NOP

conditionI:
sll     $s4, $s1, 2     			# Byte addressing i 
									# Stall for $s4
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP

slt     $t0, $s4, $s6   			# i < n-1 and throw result into $t0
									# Stall for $t0
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP

beq		$t0, $0, exit				# if equal branch to exit
									# Wait to read
add     $0, $0, $0					# NOP

conditionJ:
sll     $s5, $s2, 2     			# Byte addressing j
									# Stall for $s5
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP

slt     $t0, $s5, $s7   			# j < m and throw result into $t0
add     $a1, $a0, $s5   			# Address of arr[j]
									# Stall for $t0
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP

beq		$t0, $0, incrementI			# if equal branch to incramenting of I
									# Wait to read
add     $0, $0, $0					# NOP

lw      $t1, 0($a1)      			# arr[j], prep specific elements
lw      $t2, 4($a1)      			# arr[j+1], more preping
									# Stall for $t1, and $t2
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP

slt     $t3, $t2, $t1   			# arr[j+1] < arr[j] and throw result in $t3
									# Stall for $t3
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP

beq     $t3, $0, incrementJ 		#if equal branch to Incramenting of J
									# Wait to read
add     $0, $0, $0					# NOP

addi    $t4, $t1, 0    			    # temp = arr[j]
									# Stall for $t4
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP

sw      $t2, 0($a1)      			# arr[j] = arr[j+1]
sw      $t4, 4($a1)      			# arr[j+1] = temp
j incrementJ
									# Wait to read
add     $0, $0, $0					# NOP



incrementI:
addi    $s1, $s1, 1    		        # i++
add     $s2, $0, $0     			# j=0
									# Stall for $s1
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP

sub     $s3, $s0, $s1   			# m = n-i-1
									# Stall for $s3
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP

sll     $s7, $s3, 2     			# Byte addressing m
j conditionI
									# Wait to read
add     $0, $0, $0					# NOP



incrementJ:
addi    $s2, $s2, 1    			    # j++
									# Stall for $s2
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP
add     $0, $0, $0					# NOP

j conditionJ
									# Wait to read
add     $0, $0, $0					# NOP

exit:
addi  $2, $0, 10      		# Place "10" in $v0 to signal an "exit" or "halt"
syscall                		# Actually cause the halt




