# Author : ENLIANG LI
# Netid : eli9
# Date : 9/10/2019
# please change the "input" at the bottom for different results



########### registers table ##########
# x0 zeros
# x1 input
# x2 inner loop counter
# x3 intermediate results
# x7 number 2 for comparision
# x8 where final result stores

factorial.s:
.align 4
.section .text
.globl _start

_start:
    lw x1, input

    lw x7, two

    lw x2, zeros
    lw x3, zeros
    lw x8, zeros # clear the registers for use

    addi x3, x1, 0 # X3 <= X1
    addi x8, x1, 0 # x8 <= X1
    blt x7, x1, large_loop

direct_answer:
    beq x0, x0, halt # if input is smaller eaqul 2, direct output 2! = 2, 1! =1

large_loop:
    addi x2, x1, -2 # define the current inner loop counter

inner_loop:
    add x8, x8, x3 # X8 <= X8 + X3
    addi x2, x2, -1 # X2 <= X2 - 1
    blt x0, x2, inner_loop

    addi x1, x1, -1 # X1 <= X1 - 1
    addi x3, x8, 0 # load previous intermediate result in to x3
    blt x7, x1, large_loop # branch if next input smaller than 2

halt:
    beq x0, x0, halt

######################## DATA #########################
.section .rodata

input:      .word 0x00000008   # << Change this one for different factorial!! (Current is 'd8)

###### DO NOT TOUCH !!!! ##############################
two:        .word 0x00000002
zeros:      .word 0x00000000
#######################################################
