
RCC_BASE             EQU     0x40023800
GPIOA_BASE           EQU     0x40020000
UART2_BASE           EQU     0x40004400

AHB1ENR_OFFSET       EQU     0x30
APB1ENR_OFFSET       EQU     0x40
GPIOA_MODER_OFFSET   EQU     0x00
GPIOA_AFRL_OFFSET    EQU     0x20
GPIOA_BSRR_OFFSET    EQU     0x18

UART2_SR_OFFSET      EQU     0x00
UART2_DR_OFFSET      EQU     0x04
UART2_BRR_OFFSET     EQU     0x08
UART2_CR1_OFFSET     EQU     0x0C
UART2_CR2_OFFSET     EQU     0x10
UART2_CR3_OFFSET     EQU     0x14

RCC_AHB1ENR          EQU     RCC_BASE + AHB1ENR_OFFSET
RCC_APB1ENR          EQU     RCC_BASE + APB1ENR_OFFSET
GPIOA_MODER          EQU     GPIOA_BASE + GPIOA_MODER_OFFSET
GPIOA_AFRL           EQU     GPIOA_BASE + GPIOA_AFRL_OFFSET
GPIOA_BSRR           EQU     GPIOA_BASE + GPIOA_BSRR_OFFSET
UART2_SR             EQU     UART2_BASE + UART2_SR_OFFSET
UART2_DR             EQU     UART2_BASE + UART2_DR_OFFSET
UART2_BRR            EQU     UART2_BASE + UART2_BRR_OFFSET
UART2_CR1            EQU     UART2_BASE + UART2_CR1_OFFSET
UART2_CR2            EQU     UART2_BASE + UART2_CR2_OFFSET
UART2_CR3            EQU     UART2_BASE + UART2_CR3_OFFSET

GPIOA_EN             EQU     1 << 0
UART2_EN             EQU     1 << 17
AF7_SLT              EQU     0x7700        
GPIOA_ALT_SLT        EQU     0xA0         
MODER5_OUT           EQU     1 << 10       

TX_BF_FLG            EQU     0x80
RX_BF_FLG            EQU     0x20

BRR_CNF              EQU     0x0683        
CR1_CNF              EQU     0x000C
CR2_CNF              EQU     0x0000
CR3_CNF              EQU     0x0000
UART2_CR1_EN         EQU     0x2000
ONESEC               EQU     5333333

BSRR_5_SET           EQU     1 << 5
BSRR_5_RESET         EQU     1 << (5 + 16) 

CR                   EQU     0x0D
LF                   EQU     0x0A
BS                   EQU     0x08
ESC                  EQU     0x1B
SPA                  EQU     0x20
DEL                  EQU     0x7F

AREA |.text|, CODE, READONLY, ALIGN=2
THUMB
ENTRY
EXPORT __main

__main
    BL UART_Init

loop
    BL UART_ReadChar
    BL LED_Blink
    MOV R0, #0x59            
    BL UART_WriteChar
    B loop

UART_Init
    ; Enable GPIOA clock
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
    STR R1, [R0]

    LDR R0, =GPIOA_MODER
    LDR R1, [R0]
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

    LDR R0, =UART2_CR1
    LDR R1, [R0]
    ORR R1, #UART2_CR1_EN
    STR R1, [R0]

    BX LR

UART_ReadChar
    LDR R1, =UART2_SR
wait_rx
    LDR R2, [R1]
    AND R2, #RX_BF_FLG
    CMP R2, #0
    BEQ wait_rx
    LDR R0, =UART2_DR
    LDR R0, [R0]
    BX LR

UART_WriteChar
    LDR R1, =UART2_SR
wait_tx
    LDR R2, [R1]
    AND R2, #TX_BF_FLG
    CMP R2, #0
    BEQ wait_tx
    UXTAB R1, R0, R0
    LDR R2, =UART2_DR
    STR R1, [R2]
    BX LR

Delay
    SUBS R3, R3, #1
    BNE Delay
    BX LR

LED_Blink
    MOV R3, R0
    CMP R3, #0x31         ; ASCII for '1'
    BEQ pt0
    BX LR

pt0
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

    BL UART_ReadChar

    BX LR

ALIGN
END
