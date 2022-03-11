## fibonacci.S

    .text                          # code section 
    .global fibonacci_asm          # declar the sum_asm function as a  global function
    .type fibonacci_asm, @function # define sum_asm as a function 
fibonacci_asm:

    # Write your assembly code funtion here.
    # Please notice the rules of calling convention.
fibonacci:
    ## fibonacci function
    #beq a0, x0  is_zero  # examine if a0 is zero
    li t1, 1
    ble a0, t1, is_one # examine if a0 is onc
    # n > 1
    addi   sp, sp, -8 		  #make room for ra and a0 
    sw     ra, 0(sp)          # store return address
    sw     a0, 4(sp)          # store temp data
    addi   a0, a0, -1	      # Now n-1 in a0
    jal fibonacci		      # Calculate fibo(n-1)
    lw t0, 4(sp)              # get original n from stack
    sw a0, 4(sp)              # store fibo(n-1) to stack in same place
    addi a0, t0, -2		      # Now n-2 in a0 
    jal fibonacci	          # Calculate fibo(n-2)  VVV a0 = fibo(n-2) 
    lw t0, 4(sp)              # Get result of fibo(n-1) from stack  VVV t0 = fibo(n-1)
    add a0, a0, t0		      # add fibo(n-1) and fibo(n-2)
    lw ra, 0(sp)		      # Get return address from stack
    addi sp, sp, 8
is_zero:
    ret                       #if a0 = 0 return 0   so we can ret directly
is_one:
	ret   
    .size fibonacci_asm, .-fibonacci_asm