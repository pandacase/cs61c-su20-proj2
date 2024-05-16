.import ../../src/read_matrix.s
.import ../../src/utils.s

.data
file_path: .asciiz "inputs/test_read_matrix/test_input.bin"

.text
main:
    # Read matrix into memory
    la a0, file_path
    addi sp, sp, -8
    addi a1, sp, 0
    addi a2, sp, 4
    jal read_matrix

    # Print out elements of matrix
    # a0 has been the pointer to the matrix in memory
    lw a1, 0(sp)
    lw a2, 4(sp)
    jal print_int_array
    addi sp, sp, 8

    # Terminate the program
    jal exit