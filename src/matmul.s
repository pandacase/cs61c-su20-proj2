.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
#   The order of error codes (checked from top to bottom):
#   If the dimensions of m0 do not make sense, 
#   this function exits with exit code 2.
#   If the dimensions of m1 do not make sense, 
#   this function exits with exit code 3.
#   If the dimensions don't match, 
#   this function exits with exit code 4.
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# =======================================================
matmul: # use t0~t1, a0~a6, s0~s8

    # Error checks
    li t0, 1
    blt a1, t0, err_exit_2
    blt a2, t0, err_exit_2
    blt a4, t0, err_exit_3
    blt a5, t0, err_exit_3
    bne a2, a4, err_exit_4

    # Prologue
    addi sp, sp, -36
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)
    sw s7, 28(sp)
    sw s8, 32(sp)

    mv s0, a0   # m0
    mv s1, a1   # row of m0
    mv s2, a2   # column of m0
    mv s3, a3   # m1
    mv s4, a4   # row of m1
    mv s5, a5   # column of m1
    mv s6, a6   # result: d
    li s7, 0    # index i
    #  s8 will be index j

outer_loop_start:
    bge s7, s1, outer_loop_end
    
    li s8, 0        # int j = 0

    mul t0, s7, s2  # t0 = i * col0
    slli t0, t0, 2  # t0 = (i * col0) * 4 bytes

inner_loop_start:
    bge s8, s5, inner_loop_end

    mv t1, s8       # t0 = j
    slli t1, t1, 2  # t0 = j * 4

    # set args for calling the dot
    add a0, s0, t0  # updated m0
    add a1, s3, t1  # updated m1
    mv a2, s2       # column of m0
    li a3, 1        # a3 = 1
    mv a4, s5       # column of m1

    addi sp, sp, -8
    sw ra, 0(sp)
    sw t0, 4(sp)

    jal dot  # jump to dot and save position to ra
    sw a0, 0(s6)
    addi s6, s6, 4
    
    lw t0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 8

    addi s8, s8, 1  # j++

    j inner_loop_start

inner_loop_end:
    addi s7, s7, 1  # i++
    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    lw s7, 28(sp)
    lw s8, 32(sp)
    addi sp, sp, 36
    
    ret

err_exit_2:
    li a1, 2
    jal exit2

err_exit_3:
    li a1, 3
    jal exit2

err_exit_4:
    li a1, 4
    jal exit2

# int matmul(
#     int* m0, int row0, int col0, 
#     int* m1, int row1, int col1m
#     int* d
# ) {
#     for (int i = 0; i < row0, ++i) {
#         for (int j = 0; j < col1, ++j) {
#             d[i][j] = dot(m0, m1, col0, 1, col1);
#         }
#     }
# }