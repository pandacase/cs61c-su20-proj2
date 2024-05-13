.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
#
# If the length of the vector is less than 1, 
# this function exits with error code 5.
# If the stride of either vector is less than 1,
# this function exits with error code 6.
# =======================================================
dot: # use t0~t1, a0~a4, s0~s1
    # Error checks
    li t0, 1
    blt a1, t0, err_exit_5 # if a1 < 1 then err_exit_5
    blt a3, t0, err_exit_6 # if a3 < 1 then err_exit_6
    blt a4, t0, err_exit_6 # if a4 < 1 then err_exit_6

    # Prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)

    # Initialize variables
    mv s0, x0  # s0: res = 0
    mv s1, x0  # s1:  i  = 0

loop_start:
    beq s1, a2, loop_end    # if s1 == a2 then loop_end
    
    mul t0, s1, a3          # t0 = i * stride1
    # bge t0, a2, loop_end    # if t0 >= n, goto loop_end
    slli t0, t0, 2          # t0 = (i * stride1) * 4
    add t0, a0, t0          # t0 = arr1 + (i * stride1) * 4
    lw t0, 0(t0)            # t0 = arr1[index1]

    mul t1, s1, a4          # t1 = i * stride2
    # bge t1, a2, loop_end    # if t1 >= n, goto loop_end
    slli t1, t1, 2          # t1 = (i * stride2) * 4
    add t1, a1, t1          # t1 = arr2 + (i * stride2) * 4
    lw t1, 0(t1)            # t1 = arr2[index2]

    mul t0, t0, t1          # t0 = arr1[index1] * arr2[index2]
    add s0, s0, t0          # res += t0

    addi s1, s1, 1          # i++
    j loop_start

loop_end:
    mv a0, s0               # a0 = res

    # Epilogue
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 8
    
    ret

err_exit_5:
    li a0, 17
    li a1, 5
    ecall
    ret

err_exit_6:
    li a0, 17
    li a1, 6
    ecall
    ret

# int dot(int* arr1, int* arr2, int n, int stride1, int stride2) {
#     int res = 0;
#     for (int i = 0; i < n; ++i) {
#         int index1 = i * stride1;
#         int index2 = i * stride2;
#         res = res + arr1[index1] * arr2[index2];
#     }
#     return res;
# }