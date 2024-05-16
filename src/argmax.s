.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
#
# If the length of the vector is less than 1, 
# this function exits with error code 7.
# =================================================================
argmax: # use t0~t1, a0~a1, s0~s1
    # Error checks
    li t0, 1
    blt a1, t0, err_exit_7 # if a1 < t0 then err_exit_7

    # Prologue
    addi sp, sp, -8
    sw s0, 0(sp)
    sw s1, 4(sp)

    addi s0, a0, 0      # move a0 to s0 (a0 = arr)
    addi s1, a1, 0      # move a1 to s1 (a1 = n)

    addi a0, x0, 0      # a0 = 0 ( int res = 0 )
    lw t0, 0(s0)        # t0 = arr[0] ( int tmp = arr[0] )
    addi t1, x0, 1      # t1 = 1 ( int i = 1 )
    addi s0, s0, 4      # arr += 4
loop_start:
    bge t1, s1, loop_end        # if t1 >= s1 then loop_end
    lw t2, 0(s0)                # t2 = arr[i]
    bge t0, t2, loop_continue   # if t0(tmp) >= t2(arr[i]) then loop_continue
    addi a0, t1, 0
    addi t0, t2, 0

loop_continue:
    addi t1, t1, 1  # i++
    addi s0, s0, 4  # arr += 4(bytes)
    j loop_start

loop_end:
    # Epilogue
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 8

	ret

err_exit_7:
    li a0, 17
    li a1, 7
    ecall
    ret

# int argmax(int* arr, int n) {
#     int res = 0;
#     int tmp = arr[0];
#     for (int i = 1; i < n; ++i) {
##        if (tmp < arr[i]) {
#             res = i;
#             tmp = arr[i];
#         } else {
#             continue;
#         }
#     }
# }