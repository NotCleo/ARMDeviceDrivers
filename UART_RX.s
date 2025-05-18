RCC_BASE            EQU     0x40023800
AHB1ENR_OFFSET      EQU     0x30
RCC_AHB1ENR         EQU     RCC_BASE + AHB1ENR_OFFSET

GPIOA_BASE          EQU     0x40020000
GPIOA_MODER_OFFSET  EQU     0x00
GPIOA_MODER         EQU     GPIOA_BASE + GPIOA_MODER_OFFSET
GPIOA_AFRL_OFFSET   EQU     0x20
GPIOA_AFRL          EQU     GPIOA_BASE + GPIOA_AFRL_OFFSET
GPIOA_BSRR_OFFSET   EQU     0x18
GPIOA_BSRR          EQU     GPIOA_BASE + GPIOA_BSRR_OFFSET

RCC_APB1ENR_OFFSET  EQU     0x40
RCC_APB1ENR         EQU     RCC_BASE + RCC_APB1ENR_OFFSET

UART2_BASE          EQU     0x40004400
UART2_SR_OFFSET     EQU     0x00
UART2_DR_OFFSET     EQU     0x04
UART2_BRR_OFFSET    EQU     0x08
UART2_CR1_OFFSET    EQU     0x0C
UART2_CR2_OFFSET    EQU     0x10
UART2_CR3_OFFSET    EQU     0x14

UART2_SR            EQU     UART2_BASE + UART2_SR_OFFSET
UART2_DR            EQU     UART2_BASE + UART2_DR_OFFSET
UART2_BRR           EQU     UART2_BASE + UART2_BRR_OFFSET
UART2_CR1           EQU     UART2_BASE + UART2_CR1_OFFSET
UART2_CR2           EQU     UART2_BASE + UART2_CR2_OFFSET
UART2_CR3           EQU     UART2_BASE + UART2_CR3_OFFSET

; Constants
GPIOA_EN            EQU     (1 << 0)
UART2_EN            EQU     (1 << 17)

GPIOA_ALT_SLT       EQU     0x80     
AF7_SLT             EQU     0x7700   
MODER5_OUT          EQU     (1 << 10) 

BSRR_5_SET          EQU     (1 << 5)
BSRR_5_RESET        EQU     (1 << 21)

BRR_CNF             EQU     0x008B  
CR1_CNF             EQU     0x0004   
CR2_CNF             EQU     0x0000  
CR3_CNF             EQU     0x0000   

UART2_CR1_EN        EQU     0x2000   
TX_BF_FLG           EQU     0x80     
RX_BF_FLG           EQU     0x20     

ASCII_1             EQU     0x31
ONESEC              EQU     5333333

AREA |.text|, CODE, READONLY, ALIGN=2
THUMB
ENTRY
EXPORT __main

__main
    BL UART_Init

main_loop
    BL UART_ReadChar
    BL LED_Blink
    B main_loop

UART_Init
    LDR R0, =RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, #GPIOA_EN
    STR R1, [R0]

    LDR R0, =RCC_APB1ENR
    LDR R1, [R0]
    ORR R1, #UART2_EN
    STR R1, [R0]

    LDR R0, =GPIOA_AFRL
    LDR R1, [R0]
    ORR R1, #AF7_SLT
    STR R1, [R0]

    LDR R0, =GPIOA_MODER
    LDR R1, [R0]
    ORR R1, #GPIOA_ALT_SLT
    ORR R1, #MODER5_OUT
    STR R1, [R0]

    LDR R0, =UART2_BRR
    MOVW R1, #BRR_CNF
    STR R1, [R0]

    LDR R0, =UART2_CR1
    MOV R1, #CR1_CNF
    STR R1, [R0]

    LDR R0, =UART2_CR2
    MOV R1, #CR2_CNF
    STR R1, [R0]

    LDR R0, =UART2_CR3
    MOV R1, #CR3_CNF
    STR R1, [R0]

    ; Enable UART
    LDR R0, =UART2_CR1
    LDR R1, [R0]
    ORR R1, #UART2_CR1_EN
    STR R1, [R0]

    BX LR

UART_ReadChar
    LDR R1, =UART2_SR
rx_wait
    LDR R2, [R1]
    AND R2, #RX_BF_FLG
    CMP R2, #0
    BEQ rx_wait
    LDR R0, =UART2_DR
    LDR R0, [R0]
    BX LR

LED_Blink
    MOV R3, R0
    CMP R3, #ASCII_1
    BEQ led_on
    BX LR

led_on
    MOVS R0, #BSRR_5_SET
    LDR R1, =GPIOA_BSRR
    STR R0, [R1]
    LDR R3, =ONESEC
    BL Delay

    MOVS R0, #BSRR_5_RESET
    LDR R1, =GPIOA_BSRR
    STR R0, [R1]
    LDR R3, =ONESEC
    BL Delay
    BX LR

UART_WriteChar
    LDR R1, =UART2_SR
tx_wait
    LDR R2, [R1]
    AND R2, #TX_BF_FLG
    CMP R2, #0
    BEQ tx_wait
    UXTBA R1, R0
    LDR R2, =UART2_DR
    STR R1, [R2]
    BX LR

Delay
    SUBS R3, R3, #1
    BNE Delay
    BX LR

ALIGN
END
