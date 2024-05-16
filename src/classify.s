.globl classify

.text
classify: # use t0, a0~a6, s0~s8
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # 
    # If there are an incorrect number of command line args,
    # this function returns with exit code 49.
    #
    # Usage:
    #   main.s -m -1 <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

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

    # =====================================
    # SAVED REGISTERS
    # =====================================

    mv s0, ra   # return address
    mv s1, a1   # (char**) argv
    mv s2, a2   # print_classification flag
    #  s3 will be pointer to m0 matrix in memory
    #  s4 will be pointer to m1 matrix in memory
    #  s5 will be pointer to input matrix in memory
    #  s6 will be pointer to d1: m0 * input (then apply relu)
    #  s7 will be pointer to d2: m1 * d1 (then apply argmax)
    #  s8 will be the size of d1/d2 (tempary saved)

    # =====================================
    # LOAD MATRICES
    # =====================================

error_checks_for_classify:
    li t0, 5
    bne a0, t0, err_exit_49

    # Load pretrained m0
load_m0_for_classify:
    # set args for calling the read_matrix
    lw a0, 4(s1)    # index 1 of agrv: pointer to m0's filename address
    addi sp, sp, -8 # ! will restore at the end
    addi a1, sp, 0  # pointer to m0's row
    addi a2, sp, 4  # pointer to m0's column

    # call read_matrix
    jal read_matrix
    # now a0 = the pointer to the m0 in memory (! new allocated)
    mv s3, a0

    # Load pretrained m1
load_m1_for_classify:
    # set args for calling the read_matrix
    lw a0, 8(s1)    # index 2 of agrv: pointer to m1's filename address
    addi sp, sp, -8 # ! will restore at the end
    addi a1, sp, 0  # pointer to m1's row
    addi a2, sp, 4  # pointer to m1's column

    # call read_matrix
    jal read_matrix
    # now a0 = the pointer to the m1 in memory (! new allocated)
    mv s4, a0

    # Load input matrix
load_input_mat_for_classify:
    # set args for calling the read_matrix
    lw a0, 12(s1)   # index 3 of agrv: pointer to input's filename address
    addi sp, sp, -8 # ! will restore at the end
    addi a1, sp, 0  # pointer to input's row
    addi a2, sp, 4  # pointer to input's column

    # call read_matrix
    jal read_matrix
    # now a0 = the pointer to the input in memory (! new allocated)
    mv s5, a0

    # =====================================
    # RUN LAYERS
    # =====================================
    # 1. LINEAR LAYER:    m0 * input
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)

    # now the data from top of stack is as follow:
    # sp +  0: row of input
    # sp +  4: col of input
    # sp +  8: row of m1
    # sp + 12: col of m1
    # sp + 16: row of m0
    # sp + 20: col of m0

linear_layer_1_for_classify:  # m0 * input
    # set args: allocate memory for d1 ( d1 = m0 * input)
    lw a0, 16(sp)   # row of m0
    lw t0, 4(sp)    # col of input
    mul a0, a0, t0  # the # of d1's words
    mv s8, a0       # save it to s8
    slli a0, a0, 2  # the # of d1's bytes

    # call malloc
    jal malloc
    # now a0 = pointer to d1
    mv a6, a0
    # set args for calling the matmul
    
    mv a0, s3       # pointer to m0
    lw a1, 16(sp)   # row of m0
    lw a2, 20(sp)   # col of m0
    mv a3, s5       # pointer to input
    lw a4, 0(sp)    # row of input
    lw a5, 4(sp)    # col of input
    #  a6 has been the pointer to d1

    # call matmul
    jal matmul
    # now a6 = d1 (with result value)
    mv s6, a6       # save it to s6

nonlinear_layer_for_classify: # ReLU(m0 * input)
    # set args for calling the relu
    mv a0, s6       # the pointer to d1 array
    mv a1, s8       # the # of elements in the d1 array

    # call matmul
    jal relu
    # now a0 = d1 (with result value after RELU)
    mv s6, a0       # save it to s6

linear_layer_2_for_classify:  # m1 * ReLU(m0 * input)
    # set args: allocate memory for d2 ( d2 = m1 * ReLU(m0 * input) )
    lw a0, 8(sp)    # row of m1
    lw t0, 4(sp)    # col of input
    mul a0, a0, t0  # the # of d2's words
    mv s8, a0       # save it to s8
    slli a0, a0, 2  # the # of d2's bytes

    # call malloc
    jal malloc
    # now a0 = pointer to d2
    mv a6, a0

    # set args for calling the matmul
    mv a0, s4       # pointer to m1
    lw a1, 8(sp)    # row of m1
    lw a2, 12(sp)   # col of m1
    mv a3, s6       # pointer to d1
    lw a4, 16(sp)   # row of d1 (row of m0)
    lw a5, 4(sp)    # col of d1 (col of input)
    #  a6 has been the pointer to d2

    # call matmul
    jal matmul
    # now a6 = d2 (with result value)
    mv s7, a6       # save it to s7

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix

write_output_matrix_for_classify:
    # set args for calling the write_matrix
    lw a0, 16(s1)   # index 4 of agrv: pointer to output's filename address
    mv a1, s7
    lw a2, 8(sp)   # row of m1
    lw a3, 4(sp)   # col of input

    # call write_matrix
    jal write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax

calculate_label_for_classify:
    # set args for calling the argmax
    mv a0, s7       # the pointer to d2 array
    mv a1, s8       # the # of elements in the d2 array

    # call argmax
    jal argmax
    # now a0 = the first index of the largest element

print_label_for_classify:
    # check the print_classification flag
    li t0, 0
    bne s2, t0, free_and_exit_for_classify
    # Print classification
    mv a1, a0       # the integer to print
    jal print_int   # print the int
    # Print newline afterwards for clarity
    li a1, '\n'     # the newline to print
    jal print_char  # print the char

free_and_exit_for_classify:
    # free all allocated memory on heap
    mv a0, s3
    jal free        # free m0
    mv a0, s4
    jal free        # free m1
    mv a0, s5
    jal free        # free input
    mv a0, s6
    jal free        # free d1
    mv a0, s7
    jal free        # free d2

    # restore sp and ra
    addi sp, sp, 24
    mv ra, s0

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


err_exit_49: # the # of agrs not expected
    li a1, 49
    jal exit2
