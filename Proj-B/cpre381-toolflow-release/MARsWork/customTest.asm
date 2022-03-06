.text

addi $3, $0, 15
sw $3, 0($3)

addi $2, $0, 0xFFFF0014
syscall
