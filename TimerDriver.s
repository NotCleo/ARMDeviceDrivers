

RCC_BASE            EQU     0x40023800
GPIOA_BASE          EQU     0x40020000
TIM2_BASE           EQU     0x40000000

AHB1ENR_OFFSET      EQU     0x30
APB1ENR_OFFSET      EQU     0x40

RCC_AHB1ENR         EQU     RCC_BASE + AHB1ENR_OFFSET
RCC_APB1ENR         EQU     RCC_BASE + APB1ENR_OFFSET

GPIOA_MODER_OFFSET  EQU     0x00
GPIOA_ODR_OFFSET    EQU     0x14
GPIOA_BSRR_OFFSET   EQU     0x18

GPIOA_MODER         EQU     GPIOA_BASE + GPIOA_MODER_OFFSET
GPIOA_ODR           EQU     GPIOA_BASE + GPIOA_ODR_OFFSET
GPIOA_BSRR          EQU     GPIOA_BASE + GPIOA_BSRR_OFFSET

TIM2_CR1_OFFSET     EQU     0x00
TIM2_SR_OFFSET      EQU     0x10
TIM2_CNT_OFFSET     EQU     0x24
TIM2_PSC_OFFSET     EQU     0x28
TIM2_ARR_OFFSET     EQU     0x2C

TIM2_CR1            EQU     TIM2_BASE + TIM2_CR1_OFFSET
TIM2_SR             EQU     TIM2_BASE + TIM2_SR_OFFSET
TIM2_CNT            EQU     TIM2_BASE + TIM2_CNT_OFFSET
TIM2_PSC            EQU     TIM2_BASE + TIM2_PSC_OFFSET
TIM2_ARR            EQU     TIM2_BASE + TIM2_ARR_OFFSET

PSC_CNF             EQU     1600 - 1        ; Prescaler: 16 MHz / 1600 = 10 kHz
ARR_CNF             EQU     10000 - 1       ; Auto-reload: 10 kHz / 10000 = 1 Hz
CNT_CNF             EQU     0               ; Reset Counter
CR1_CNF             EQU     1               ; Enable Timer

GPIOA_EN            EQU     1 << 0
TIM2_EN             EQU     1 << 0
MODER5_OUT          EQU     1 << 10
TIM2_SR_UIF         EQU     1 << 0
BSRR_5_SET          EQU     1 << 5
BSRR_5_RESET        EQU     1 << (5 + 16)

AREA    RESET, CODE, READONLY
ENTRY
EXPORT  __main

__main
    LDR     R0, =RCC_AHB1ENR
    LDR     R1, [R0]
    ORR     R1, R1, #GPIOA_EN
    STR     R1, [R0]

    LDR     R0, =RCC_APB1ENR
    LDR     R1, [R0]
    ORR     R1, R1, #TIM2_EN
    STR     R1, [R0]

    LDR     R0, =GPIOA_MODER
    LDR     R1, [R0]
    BIC     R1, R1, #(3 << 10)
    ORR     R1, R1, #MODER5_OUT
    STR     R1, [R0]

    LDR     R0, =TIM2_PSC
    MOV     R1, #PSC_CNF
    STR     R1, [R0]

    LDR     R0, =TIM2_ARR
    MOV     R1, #ARR_CNF
    STR     R1, [R0]

    LDR     R0, =TIM2_CNT
    MOV     R1, #CNT_CNF
    STR     R1, [R0]

    LDR     R0, =TIM2_CR1
    MOV     R1, #CR1_CNF
    STR     R1, [R0]

main_loop
wait_loop
    LDR     R0, =TIM2_SR
    LDR     R1, [R0]
    TST     R1, #TIM2_SR_UIF
    BEQ     wait_loop

    LDR     R0, =TIM2_SR
    MOV     R1, #0
    STR     R1, [R0]

    LDR     R0, =GPIOA_ODR
    LDR     R1, [R0]
    EOR     R1, R1, #(1 << 5)
    STR     R1, [R0]

    B       main_loop

    END
