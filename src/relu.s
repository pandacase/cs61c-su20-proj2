.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
#
# If the length of the vector is less than 1, 
# this function exits with error code 8.
# ==============================================================================
relu:
    # Error checks
    li t0, 1
    blt a1, t0, err_exit_8 # if a1 < t0 then err_exit_8

    # Prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)

    addi s0, a0, 0      # move a0 to s0 (a0 = arr)
    addi s1, a1, 0      # move a1 to s1 (a1 = n)

    addi t0, x0, 0      # t0 = 0 ( int i = 0 )

loop_start:
    bge t0, s1, loop_end        # if t0 >= s1 then loop_end
    lw t1, 0(s0)                # t1 = arr[0]
    bge t1, x0, loop_continue   # if t1 >= x0 then loop_continue
    addi t1, x0, 0              # t1 = 0
    sw t1, 0(s0)                # arr[0] = 0

loop_continue:
    addi t0, t0, 1  # i++
    addi s0, s0, 4  # arr += 4(bytes)
    j loop_start

loop_end:
    # Epilogue
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 8

	ret

err_exit_8:
    li a0, 17
    li a1, 8
    ecall
    ret


# void relu(int* arr, int n) {
#     for (int i = 0; i < n; ++i) {
##        if (arr[i] >= 0)
#             continue;
##        else
#             arr[i] = 0;
#     }
# }