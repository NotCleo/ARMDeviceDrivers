; Blinking the LED on PA5 but this time via BSRR register (STM32F4, ARM Cortex-M4)

RCC_BASE              EQU     0x40023800
GPIOA_BASE            EQU     0x40020000

RCC_AHB1ENR_OFFSET    EQU     0x30
GPIOA_MODER_OFFSET    EQU     0x00
GPIOA_BSRR_OFFSET     EQU     0x18    

RCC_AHB1ENR           EQU     RCC_BASE + RCC_AHB1ENR_OFFSET
GPIOA_MODER           EQU     GPIOA_BASE + GPIOA_MODER_OFFSET
GPIOA_BSRR            EQU     GPIOA_BASE + GPIOA_BSRR_OFFSET

GPIOA_EN              EQU     (1 << 0)     
MODER5_OUT            EQU     (1 << 10)    
PIN5_SET              EQU     (1 << 5)     
PIN5_RESET            EQU     (1 << 21)    

DELAY_VAL             EQU     800000       

    AREA |.text|, CODE, READONLY, ALIGN=2
    THUMB
    ENTRY
    EXPORT __main

__main
    BL      GPIOA_Init
    BL      BlinkLoop

GPIOA_Init
    ; Enable GPIOA clock
    LDR     R0, =RCC_AHB1ENR
    LDR     R1, [R0]
    ORR     R1, R1, #GPIOA_EN
    STR     R1, [R0]

    LDR     R0, =GPIOA_MODER
    LDR     R1, [R0]
    BIC     R1, R1, #(3 << 10)     
    ORR     R1, R1, #MODER5_OUT   
    STR     R1, [R0]

    BX      LR


BlinkLoop
    LDR     R4, =GPIOA_BSRR   
blink_loop
    LDR     R1, =PIN5_SET
    STR     R1, [R4]
    LDR     R2, =DELAY_VAL
delay_on
    SUBS    R2, R2, #1
    BNE     delay_on
    LDR     R1, =PIN5_RESET
    STR     R1, [R4]
    LDR     R2, =DELAY_VAL
delay_off
    SUBS    R2, R2, #1
    BNE     delay_off

    B       blink_loop

    ALIGN
    END
