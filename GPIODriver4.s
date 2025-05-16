; LED on PA5, Button on PC13 (active low)

RCC_BASE           EQU     0x40023800
GPIOA_BASE         EQU     0x40020000
GPIOC_BASE         EQU     0x40020800

RCC_AHB1ENR_OFFSET EQU     0x30
GPIO_MODER_OFFSET  EQU     0x00
GPIO_IDR_OFFSET    EQU     0x10
GPIO_BSRR_OFFSET   EQU     0x18

RCC_AHB1ENR        EQU     RCC_BASE + RCC_AHB1ENR_OFFSET
GPIOA_MODER        EQU     GPIOA_BASE + GPIO_MODER_OFFSET
GPIOA_BSRR         EQU     GPIOA_BASE + GPIO_BSRR_OFFSET
GPIOC_MODER        EQU     GPIOC_BASE + GPIO_MODER_OFFSET
GPIOC_IDR          EQU     GPIOC_BASE + GPIO_IDR_OFFSET

GPIOA_EN           EQU     (1 << 0)     
GPIOC_EN           EQU     (1 << 2)     

MODER5_OUT         EQU     (1 << 10)    
PIN5_SET           EQU     (1 << 5)     
PIN5_RESET         EQU     (1 << 21)   
PIN13_MASK         EQU     (1 << 13)   
    AREA |.text|, CODE, READONLY, ALIGN=2
    THUMB
    ENTRY
    EXPORT __main

__main
    BL      Init_GPIO
    BL      LoopCheck

Init_GPIO
    ; Enable GPIOA and GPIOC
    LDR     R0, =RCC_AHB1ENR
    LDR     R1, [R0]
    ORR     R1, R1, 
    STR     R1, [R0]

    ; Configure PA5 as output
    LDR     R0, =GPIOA_MODER
    LDR     R1, [R0]
    BIC     R1, R1, #(3 << 10)      
    ORR     R1, R1, #MODER5_OUT     
    STR     R1, [R0]

    ; Configure PC13 as input (default 00, just clear)
    LDR     R0, =GPIOC_MODER
    LDR     R1, [R0]
    BIC     R1, R1, #(3 << 26)      
    STR     R1, [R0]

    BX      LR

LoopCheck
    LDR     R4, =GPIOC_IDR
    LDR     R5, =GPIOA_BSRR    

loop
    LDR     R1, [R4]           
    TST     R1, #PIN13_MASK   

    BEQ     turn_on_led        
    B       turn_off_led       

turn_on_led
    LDR     R0, =PIN5_SET
    STR     R0, [R5]
    B       loop

turn_off_led
    LDR     R0, =PIN5_RESET
    STR     R0, [R5]
    B       loop

    ALIGN
    END
