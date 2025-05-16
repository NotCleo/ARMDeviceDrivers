    .syntax unified
    .cpu cortex-m4
    .thumb

    .equ RCC_AHB1ENR,  0x40023830
    .equ RCC_APB1ENR,  0x40023840
    .equ GPIOBEN,      (1 << 1)
    .equ I2C1EN,       (1 << 21)

    .equ GPIOB_MODER,  0x40020400
    .equ GPIOB_AFRL,   0x40020420

    .equ I2C1_CR1,     0x40005400
    .equ I2C1_CR2,     0x40005404
    .equ I2C1_CCR,     0x4000541C
    .equ I2C1_TRISE,   0x40005420
    .equ I2C1_DR,      0x40005410
    .equ I2C1_SR1,     0x40005414
    .equ I2C1_SR2,     0x40005418

    .text
    .global main

main:
    LDR R0, =RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, R1, #GPIOBEN
    STR R1, [R0]

    LDR R0, =RCC_APB1ENR
    LDR R1, [R0]
    ORR R1, R1, 
    STR R1, [R0]

    LDR R0, =GPIOB_MODER
    LDR R1, [R0]
    BIC R1, R1, #(0xF << 12)    
    ORR R1, R1, #(0xA << 12)    
    STR R1, [R0]

    LDR R0, =GPIOB_AFRL
    LDR R1, [R0]
    BIC R1, R1, #(0xFF << 24)
    ORR R1, R1, #(0x44 << 24)  
    STR R1, [R0]

    LDR R0, =I2C1_CR2
    MOV R1, #42        
    STR R1, [R0]

    LDR R0, =I2C1_CCR
    MOV R1, #210       
    STR R1, [R0]

    LDR R0, =I2C1_TRISE
    MOV R1, #43        
    STR R1, [R0]

    LDR R0, =I2C1_CR1
    MOV R1, #1
    STR R1, [R0]

    LDR R0, =I2C1_CR1
    LDR R1, [R0]
    ORR R1, R1, #(1 << 8)    
    STR R1, [R0]

Wait_SB:
    LDR R0, =I2C1_SR1
    LDR R1, [R0]
    TST R1, #(1 << 0)       
    BEQ Wait_SB

    LDR R0, =I2C1_DR
    MOV R1, #0x78            
    STR R1, [R0]

Wait_ADDR:
    LDR R0, =I2C1_SR1
    LDR R1, [R0]
    TST R1, #(1 << 1)        
    BEQ Wait_ADDR

    LDR R0, =I2C1_SR1
    LDR R1, [R0]
    LDR R0, =I2C1_SR2
    LDR R1, [R0]

    LDR R0, =I2C1_DR
    MOV R1, #0x55
    STR R1, [R0]

Wait_TXE:
    LDR R0, =I2C1_SR1
    LDR R1, [R0]
    TST R1, #(1 << 7)        
    BEQ Wait_TXE

    // Send STOP condition
    LDR R0, =I2C1_CR1
    LDR R1, [R0]
    ORR R1, R1, #(1 << 9)   
    STR R1, [R0]

loop:
    B loop
