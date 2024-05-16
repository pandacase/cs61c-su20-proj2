.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#   If any file operation fails or doesn't read the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
#
# If you receive a malloc error, exit with code 48
# If you receive an fopen error or eof, this function exits with error code 50.
# If you receive an fread error or eof, this function exits with error code 51.
# If you receive an fclose error or eof, this function exits with error code 52.
# ==============================================================================
read_matrix: # use t0~t1, a0~a3, s0~s2
    # Prologue
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)

    # ( s0 will be fp)
    mv s1, a1
    mv s2, a2

open_file_for_read_mat:
    # set args for calling the fopen
    mv a1, a0   # a1 = file path
    li a2, 0    # a2 = read only

    # call fopen
    addi sp, sp, -4
    sw ra, 0(sp)
    jal fopen  # jump to fopen and save position to ra
    lw ra, 0(sp)
    addi sp, sp, 4
    # now a0 = file descriptor
    mv s0, a0
    li t0, -1
    beq a0, t0, err_exit_50

read_row_for_read_mat:
    # set args for calling the fread: read row
    mv a1, s0   # a1 = fp
    mv a2, s1   # a2 = -> row
    li a3, 4    # read 4 bytes: 1 int

    # call fopen: read row
    addi sp, sp, -4
    sw ra, 0(sp)
    jal fread  # jump to fread and save position to ra
    lw ra, 0(sp)
    addi sp, sp, 4
    # now a0 = Number of bytes actually read.
    bne a0, a3, err_exit_51
    li t0, -1
    beq a0, t0, err_exit_51

read_column_for_read_mat:
    # set args for calling the fread: read col
    #             a1 has been fp
    mv a2, s2   # a2 = -> col
    #             a3 has been 4 (bytes)

    # call fopen: read col
    addi sp, sp, -4
    sw ra, 0(sp)
    jal fread  # jump to fread and save position to ra
    lw ra, 0(sp)
    addi sp, sp, 4
    # now a0 = Number of bytes actually read.
    bne a0, a3, err_exit_51
    li t0, -1
    beq a0, t0, err_exit_51

alloca_matrix:
    # set args for calling the malloc
    lw t0, 0(s1)    # t0 = row
    lw t1, 0(s2)    # t1 = col
    mul t1, t0, t1  # t1 = row * col
    slli t1, t1, 2  # t1 = row * col * 4 (bytes)
    mv a0, t1

    # call malloc
    addi sp, sp, -4
    sw ra, 0(sp)
    jal malloc  # jump to malloc and save position to ra
    lw ra, 0(sp)
    addi sp, sp, 4
    # now a0 = the pointer to the allocated heap memory
    li t0, -1
    beq a0, t0, err_exit_48

read_matrix_for_read_mat:
    # set args for calling the fread: read row
    mv a1, s0   # a1 = fp
    mv a2, a0   # a2 = -> allocated heap memory
    mv a3, t1   # read t1 bytes: row * col * 4 (bytes)

    # call fopen: read row
    addi sp, sp, -4
    sw ra, 0(sp)
    jal fread  # jump to fread and save position to ra
    lw ra, 0(sp)
    addi sp, sp, 4
    # now a0 = Number of bytes actually read.
    bne a0, a3, err_exit_51
    li t0, -1
    beq a0, t0, err_exit_51

close_file_for_read_mat:
    # set args for calling the fclose
    mv a1, s0   # a1 = fp

    # call fclose
    addi sp, sp, -4
    sw ra, 0(sp)
    jal fclose  # jump to fclose and save position to ra
    lw ra, 0(sp)
    addi sp, sp, 4
    # now a0 = 0 (success) or -1 (otherwise)
    li t0, -1
    beq a0, t0, err_exit_52


read_matrix_exit:
    mv a0, a2   # return: the pointer to the matrix in memory

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 12

    ret


err_exit_48: # receive a malloc error
    li a1, 48
    jal exit2

err_exit_50: # receive an fopen error or eof
    li a1, 50
    jal exit2

err_exit_51: # receive an fread error or eof
    li a1, 51
    jal exit2

err_exit_52: # receive an fclose error or eof
    li a1, 52
    jal exit2
