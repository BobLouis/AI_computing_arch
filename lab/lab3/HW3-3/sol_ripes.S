# sudoku_2x2_asm.S
   
    .text                           # code section 
    .global sudoku_2x2_asm          # declare the asm function as a global function
    .type sudoku_2x2_asm, @function # define sum_asm as a function 
sudoku_2x2_asm:

.data
source:
    .word	0
    .word	0
    .word	2
    .word	0
    .word	0
    .word	0
    .word	0
    .word	4
    .word	2
    .word	3
    .word	0
    .word	0
    .word	0
    .word	4
    .word	0
    .word	0
    
.text                           # code Section
main:
    la a0, source  # source base address a0=>test
    li a1, 0       # a1 => index
    li t3, 0       # array offset

    #caller save
    addi sp, sp, -4
    sw ra, 0(sp)
    jal solve
    lw ra, 0(sp)
    addi sp, sp, 4

    #ret
    ecall

solve:
    # first condition 
    #//if (index >= 16)
    # return true; // 如果檢查完所有的格子，回傳 True
    li  t0, 16                    # parameter 16
    bge a1, t0, solve_is_one     # index >= 16 FINISH
    # second if jump condition

    add t5, a0, t3               # base address加上offset除了第一次t3=0其它次t3都要是4
    #### t5 變成新的地址######    
    lw  t2, 0(t5)                # t2 = array[t3/4]
    #//if (test_c_data[index] > 0)               // set是一個儲存所有資料的array
    #    return solve(index + 1, test_c_data); // 如果格子中已經有值了則會往下一格判斷
    #//else
    bgt t2, x0, index_plus_solve # if not zero plus 1
    #//else
    li  t4,  1  #int n = 1 = t4
    li  s10, 5  #s10 reg 存5
    # for
loop: 
    #//else jump condition
    sw t4, 0(t5)   # store n into test_c_data //test_c_data[index] = n;

    #caller saved
    #prelude
    addi   sp, sp, -28
    sw     ra, 0(sp)  #return address
    sw     a0, 4(sp)  #source address
    sw	   a1, 8(sp)  #index
    sw     t3, 12(sp) #address offset
    sw     t4, 16(sp) #n
    sw     t2, 20(sp) #array[t3/4]
    sw     t5, 24(sp) #base address加上offset
    #jump 回來時再load
    jal    check
    lw     t5, 24(sp) 
    lw     t2, 20(sp)
    lw     t4, 16(sp)    
    lw     t3, 12(sp)    
    lw	   a1, 8(sp)    
    lw     a0, 4(sp)
    lw     ra, 0(sp)
    addi   sp, sp, 28

    # s3 is the result of the check function
    bne  s3, x0, dont_plus_1  # check == 1 => 就不加一 直接進入solve
    addi t4, t4, 1           # n++
dont_plus_1:
    beq  t4, s10, solve_is_zero #for loop 是否超過4 沒有才繼續
    beq  s3, x0, loop  #check is 0 go back to the loop

    #prelude
    addi sp, sp, -32
    sw     ra, 0(sp)
    sw     a0, 4(sp)
    sw	   a1, 8(sp)
    sw     t3, 12(sp)
    sw     t4, 16(sp)
    sw     t2, 20(sp) 
    sw     t5, 24(sp) 
    sw     s3, 28(sp) #把之前check function的答案記起來
    jal    index_plus_solve
    lw     s3, 28(sp)  #把之前check function的答案load出來去用if檢查
    lw     t5, 24(sp) 
    lw     t2, 20(sp)
    lw     t4, 16(sp)    
    lw     t3, 12(sp)    
    lw	   a1, 8(sp)    
    lw     a0, 4(sp)
    lw     ra, 0(sp)
    addi   sp, sp, 32
    # 第一次判斷完solve的結果並且存在 t1
    bne t1, x0, solve_is_one #return 1 

    addi t4, t4, 1
    beq    t4, s10,solve_is_zero   # 檢查for loop是否超過了 4
    beq    t1, x0, loop          # check function return 0 or 1 


solve_is_zero:
    li  t4, 0     #init n = 0
    sw  t4, 0(t5) #store 0 to the data 
    li  t1, 0 #solve 的 final answer
    ret




solve_is_one:
    li t1, 1 #t1 = 1 mean solve complete
    ret

index_plus_solve:
    addi a1, a1, 1  #index++
    addi t3, t3, 4  #char is 1 byte so add 4 for ripes
    j solve


###check################################
check:
    # a0 source data 地址
    # a1 = index參數初始為0 (index)  不能動
    # t3 = offset       (可隨意更動)
    # t4 = 填入數獨的數值   不能動
    # t6 = i
    # t2 可隨意更動
    # 新增
    # s系列

    li t6, 0 		    	# init i=0 # final ans store in t6
loop_test_column:
    li s0, 0                # if condition param init as zero 
    li s1, 0 
    slli t2, a1, 30         # index取餘數放在 t2
    srli t2, t2, 30         # (index%4) = t2

    slli t3, t6, 2          # t3 = i*4
    add  t2, t2, t3         # t2 = (index % 4) + i*4
    slli t2, t2, 2          ###shift for word
    add  t3, a0, t2         # new address
    lw   t3, 0(t3)          # load data to t3
    bne  t3, t4, not_one_1  # 比較 data[(index & 0b11) + (i<<2)] == n
    li   s0, 1              # if t3 == t4 => data[(index & 0b11) + (i<<2)] == n =>s0 = 1

not_one_1:
    srli t2, t2, 2          ###shift for word
    beq  t2, a1, not_one_2 
    li   s1, 1              # if t2 == a1 s1 = 1
    ######
not_one_2:
    beq  s0, x0, skip_not_one_1      # if first condition = 1 check second condition
    bne  s1, x0, check_ans_iszero   #return 0 if num is eq && not same index
skip_not_one_1:
    addi t6, t6, 1      #i++
    li   s4, 4          #check i<4
    blt  t6, s4, loop_test_column

################################
    li t6, 0  #init i=0
loop_test_row:
    li   s0, 0      # init zero (if condition)
    li   s1, 0      # init zero (if condition)
    srli t2, a1, 2  # ((index >> 2) << 2)
    slli t2, t2, 2 
    add  t2, t2, t6 #((index >> 2) << 2) + i
    slli t2, t2, 2  ###shift for word
    add  t3, a0, t2 #new address
    lw   t3, 0(t3)  # load data

    bne  t3, t4, not_one_3 #check if the data[t3] == n
    li   s0, 1             #if  data[t3] == n => s0=1
not_one_3:
    srli t2, t2, 2          ###shift for word
    beq  t2, a1, not_one_4 #check if t2 == a1 index == t2
    li   s1, 1             #if t2 == a1 s1 = 1
not_one_4:
    beq  s0, x0, skip_not_one_2   #first condition == 1 compare next
    bne  s1, x0, check_ans_iszero # return 0 in S2
skip_not_one_2:
    addi t6, t6, 1        # i++
    li   s4, 4            #i<4
    blt  t6, s4, loop_test_row

################################################################
compute_start:
##free var t2 t3 t6
#int start = (index & 0b11) - ((index & 0b11) & 1) + (((index >>2) - ((index >>2 ) &1)) << 2);
    slli t2, a1, 30     # t2 = (index %4)
    srli t2, t2, 30     # index % 4
    
    slli t3, t2, 31
    srli t3, t3, 31     #(index % 4) % 2 = t3

    srli t6, a1, 2      #index/4 = t6

    slli s5, t6, 31
    srli s5, s5, 31     #t5 = (index/4)%2
    sub  s5, t6, s5     #((index / 4)-(index / 4) % 2)
    slli s5, s5, 2      #((index / 4)-(index / 4) % 2) * 4 = s5

    #              t2            t3                     s5
    # start = (index % 4)-((index % 4) % 2)+((index / 4)-((index / 4) % 2)) * 4;
    sub  t2, t2, t3
    add  s9, t2, s5     #s9 = start
################################
    li   t6, 0   # init i=0
loop_test_sub_block:
    mv t2, s9           #把start 移到t2以利計算並且不改到s9 loop的時候t2也要重新
    li   s0, 0      # init zero (if condition)
    li   s1, 0      # init zero (if condition)
    
    add  t2, t2, t6 # start + i = t2  
    slli t2, t2, 2  ###shift for word
    add  t3, t2, a0 #new address

    lb   t3, 0(t3)  #load data[start +i]
    bne  t3, t4, not_one_5
    li   s0, 1      #if n == data[start + i] s0 = 1
not_one_5:
    srli t2, t2, 2  ###shift for word
    beq  t2, a1, not_one_6
    li   s1, 1
not_one_6:
    beq s0, x0, skip_not_one_3   #first condition not 1
    bne s1, x0, check_ans_iszero #return 0
skip_not_one_3:
    addi t6, t6, 1   # i++
    li   s4, 2       # s4 = 2 i<2
    blt  t6, s4, loop_test_sub_block

################################################################
    li   t6, 4    #init t=4
loop_test_sub_block2:

    mv   t2, s9 #s2 = start
    li   s0, 0      # init zero (if condition)
    li   s1, 0      # init zero (if condition)
    
    add  t2, t2, t6 #t2 = start + i
    slli t2, t2, 2  ###shift for word
    add  t3, t2, a0 #t3 = new address

    lb   t3, 0(t3)        # load data
    bne  t3, t4, not_one_7 #if condition
    li   s0, 1
not_one_7:
    srli t2, t2, 2         ###shift for word
    beq  t2, a1, not_one_8 #if condition
    li   s1, 1
not_one_8:
    beq  s0, x0, skip_not_one_4 #first condition not 1
    bne  s1, x0, check_ans_iszero #return 0
skip_not_one_4:
    addi t6, t6, 1        # i++
    li   s4, 6            # i<6
    blt  t6, s4,loop_test_sub_block2

################################
#final answer
check_ans_isone:
    li s3,1  # check final answer
    ret
check_ans_iszero:
    li s3,0
    ret