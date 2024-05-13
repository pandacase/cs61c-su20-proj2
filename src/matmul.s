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
matmul: # use t0~t1, a0~a6, s0~s4

    # Error checks
    li t0, 1
    blt a1, t0, err_exit_2
    blt a2, t0, err_exit_2
    blt a4, t0, err_exit_3
    blt a5, t0, err_exit_3
    bne a2, a4, err_exit_4

    # Prologue
    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)

    li s0, 0 # int i = 0

outer_loop_start:
    bge s0, a1, outer_loop_end
    
    li s1, 0        # int j = 0

    mul t0, s0, a2  # t0 = i * col0
    slli t0, t0, 2  # t0 = (i * col0) * 4
    mv s2, a0       # s2 = m0
    add s2, s2, t0  # m0 += (i * col0) * 4

inner_loop_start:
    bge s1, a5, inner_loop_end

    mv t1, s1       # t0 = j
    slli t1, t1, 2  # t0 = j * 4
    mv s3, a3       # s3 = m1
    add s3, s3, t1  # m1 += j * 4

    mv s4, a6       # s2 = d
    add s4, s4, t0  # d += (i * col0) * 4
    add s4, s4, t1  # d += j * 4

    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a3, 8(sp)
    sw a4, 12(sp)
    sw t0, 16(sp)
    sw ra, 20(sp)

    mv a0, s2       # a0 = s2 (updated m0)
    mv a1, s3       # a1 = s3 (updated m1)
    #  a2 has been col0
    li a3, 1        # a3 = 1
    mv a4, a5       # a4 = a5 (col1)

    jal dot  # jump to dot and save position to ra
    # li a0, -106
    
    sw a0, 0(s4)
    
    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a3, 8(sp)
    lw a4, 12(sp)
    lw t0, 16(sp)
    lw ra, 20(sp)
    addi sp, sp, 24

    addi s1, s1, 1  # j++

    j inner_loop_start

inner_loop_end:
    addi s0, s0, 1  # i++
    j outer_loop_start

outer_loop_end:
    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    addi sp, sp, 20
    
    ret

err_exit_2:
    li a0, 17
    li a1, 2
    ecall
    ret

err_exit_3:
    li a0, 17
    li a1, 3
    ecall
    ret

err_exit_4:
    li a0, 17
    li a1, 4
    ecall
    ret

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