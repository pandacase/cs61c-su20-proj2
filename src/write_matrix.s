.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
#   If any file operation fails or doesn't write the proper number of bytes,
#   exit the program with exit code 1.
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
#
# If you receive an fopen error or eof, this function exits with error code 53.
# If you receive an fwrite error or eof, this function exits with error code 54.
# If you receive an fclose error or eof, this function exits with error code 55.
# ==============================================================================
write_matrix: # use t0~t1, a0-a4, s0~s1
    # Prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)

    # ( s0 will be fp)
    mv s1, a1
    addi sp, sp, -8 # ! will restore at the end
    sw a2, 0(sp)
    sw a3, 4(sp)

open_file_for_write_mat:
    # set args for calling the fopen
    mv a1, a0   # a1 = file path
    li a2, 1    # a2 = write mode

    # call fopen
    addi sp, sp, -4
    sw ra, 0(sp)
    jal fopen  # jump to fopen and save position to ra
    lw ra, 0(sp)
    addi sp, sp, 4
    # now a0 = file descriptor
    mv s0, a0
    li t0, -1
    beq a0, t0, err_exit_53

write_row_and_col_for_write_mat:
    # set args for calling the fwrite
    mv a1, s0   # fp
    mv a2, sp   # the buf in memory
    li a3, 2    # write 2 items
    li a4, 4    # 4 bytes each item

    # call fwrite
    addi sp, sp, -4
    sw ra, 0(sp)
    jal fwrite
    lw ra, 0(sp)
    addi sp, sp, 4
    # now a0 = number of elements writen
    bne a0, a3, err_exit_54


write_matrix_for_write_mat:
    # set args for calling the fwrite
    mv a1, s0       # fp
    mv a2, s1       # the matrix buf
    lw t0, 0(sp)
    lw t1, 4(sp)
    mul a3, t0, t1  # row * col
    li a4, 4

    # call fwrite
    addi sp, sp, -4
    sw ra, 0(sp)
    jal fwrite
    lw ra, 0(sp)
    addi sp, sp, 4
    # now a0 = number of elements writen
    bne a0, a3, err_exit_54

close_file_for_write_mat:
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
    beq a0, t0, err_exit_55

write_matrix_exit:
    # restore sp
    addi sp, sp, 8

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 8

    ret

err_exit_53: # receive an fopen error or eof
    li a1, 53
    jal exit2

err_exit_54: # receive an fwrite error or eof
    li a1, 54
    jal exit2

err_exit_55: # receive an fclose error or eof
    li a1, 55
    jal exit2


