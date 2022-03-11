## fibonacci.S

    .text                          # code section 
    .global fibonacci_asm          # declar the sum_asm function as a  global function
    .type fibonacci_asm, @function # define sum_asm as a function 
fibonacci_asm:

    # Write your assembly code funtion here.
    # Please notice the rules of calling convention.
    
main:
    # a0 = n  input
    # caller saved
    addi   sp, sp, -4
    sw     ra, 0(sp)       # caller saved
    mv     t1, a0          # pass parameter
    jal    fibo            # jump to fibo
    lw     ra, 0(sp)       # retrieve
    addi   sp, sp, 4
    ret
   
fibo:
                            # a1 will be the final ans
    li      t2, 0           # t2 = 0
    beq     t1, t2, is_zero # a1 = n if(n == 0)
    addi    t0, t1, -1      # n - 1 
    beq     t0, t2, is_one  # if (n-1==0)
    
 
                              # caller saved
    addi   sp, sp, -8
    sw     t1, 0(sp)          # store the original  a1 = n     
    sw     ra, 4(sp)
    
    addi   t1, t1, -1         # a0 = n-1 now
    jal    fibo      # caculate fibo(n-1)
    
    lw    t0, 0(sp)          # load the original n
    sw     t1, 0(sp)          # store fibo(n-1)
    addi   t1, t0, -2
    jal    fibo               # caculate fibo(n-2)
    
    lw     t0, 0(sp)          # get fibo(n-1)
    add    t1, t1, t0         # caculate fibo(n-1) fibo(n-2)
    lw    ra,4(sp)
    mv     a0, t1             # move the final ans to a1/a0??????????
    addi   sp, sp, 8          # retrieve

    
is_zero:
    ret
is_one:
 ret



    .size fibonacci_asm, .-fibonacci_asm
