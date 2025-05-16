; LED Blink using GPIOA Pin 5 (STM32F4)
; Assume that the clock source is already config (usually HSI 16 MHz)

RCC_BASE              EQU     0x40023800
GPIOA_BASE            EQU     0x40020000

RCC_AHB1ENR_OFFSET    EQU     0x30
GPIOA_MODER_OFFSET    EQU     0x00
GPIOA_ODR_OFFSET      EQU     0x14

RCC_AHB1ENR           EQU     RCC_BASE + RCC_AHB1ENR_OFFSET
GPIOA_MODER           EQU     GPIOA_BASE + GPIOA_MODER_OFFSET
GPIOA_ODR             EQU     GPIOA_BASE + GPIOA_ODR_OFFSET

GPIOA_EN              EQU     (1 << 0)    
MODER5_OUT            EQU     (1 << 10)   
PIN5_MASK             EQU     (1 << 5)    

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
    LDR     R4, =GPIOA_ODR    ; Store ODR address in R4

blink_loop
    ; Turn LED ON (set bit 5)
    LDR     R1, [R4]
    ORR     R1, R1, #PIN5_MASK
    STR     R1, [R4]

    ; Delay
    LDR     R2, =DELAY_VAL
delay_on
    SUBS    R2, R2, #1
    BNE     delay_on

    ; Turn LED OFF (clear bit 5)
    LDR     R1, [R4]
    BIC     R1, R1, #PIN5_MASK
    STR     R1, [R4]

    ; Delay
    LDR     R2, =DELAY_VAL
delay_off
    SUBS    R2, R2, #1
    BNE     delay_off

    B       blink_loop

    ALIGN
    END
