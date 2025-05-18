RCC_BASE              EQU     0x40023800
GPIOA_BASE            EQU     0x40020000
UART2_BASE            EQU     0x40004400

AHB1ENR_OFFSET        EQU     0x30
APB1ENR_OFFSET        EQU     0x40

GPIOA_MODER_OFFSET    EQU     0x00
GPIOA_AFRL_OFFSET     EQU     0x20

UART2_SR_OFFSET       EQU     0x00
UART2_DR_OFFSET       EQU     0x04
UART2_BRR_OFFSET      EQU     0x08
UART2_CR1_OFFSET      EQU     0x0C
UART2_CR2_OFFSET      EQU     0x10
UART2_CR3_OFFSET      EQU     0x14

RCC_AHB1ENR           EQU     RCC_BASE + AHB1ENR_OFFSET
RCC_APB1ENR           EQU     RCC_BASE + APB1ENR_OFFSET
GPIOA_MODER           EQU     GPIOA_BASE + GPIOA_MODER_OFFSET
GPIOA_AFRL            EQU     GPIOA_BASE + GPIOA_AFRL_OFFSET

UART2_SR              EQU     UART2_BASE + UART2_SR_OFFSET
UART2_DR              EQU     UART2_BASE + UART2_DR_OFFSET
UART2_BRR             EQU     UART2_BASE + UART2_BRR_OFFSET
UART2_CR1             EQU     UART2_BASE + UART2_CR1_OFFSET
UART2_CR2             EQU     UART2_BASE + UART2_CR2_OFFSET
UART2_CR3             EQU     UART2_BASE + UART2_CR3_OFFSET

GPIOA_EN              EQU     1 << 0
UART2_EN              EQU     1 << 17

GPIOA_ALT_MODE        EQU     0x20        
AF7_SELECT            EQU     0x700       
BRR_VALUE             EQU     0x0683      
CR1_CONFIG            EQU     0x0008     
CR2_CONFIG            EQU     0x0000      
CR3_CONFIG            EQU     0x0000     

UART_ENABLE           EQU     0x2000      

TXE_FLAG              EQU     0x80        
CR                    EQU     0x0D
LF                    EQU     0x0A

=AREA |.text|, CODE, READONLY, ALIGN=2
THUMB
ENTRY
EXPORT __main

__main
    BL  UART_Init

loop
    MOV     R0, #'Y'
    BL      UART_WriteChar
    MOV     R0, #'E'
    BL      UART_WriteChar
    MOV     R0, #'S'
    BL      UART_WriteChar
    MOV     R0, #CR
    BL      UART_WriteChar
    MOV     R0, #LF
    BL      UART_WriteChar
    B       loop

UART_Init
    LDR     R0, =RCC_AHB1ENR
    LDR     R1, [R0]
    ORR     R1, R1, #GPIOA_EN
    STR     R1, [R0]

    LDR     R0, =RCC_APB1ENR
    LDR     R1, [R0]
    ORR     R1, R1, #UART2_EN
    STR     R1, [R0]

    LDR     R0, =GPIOA_AFRL
    LDR     R1, [R0]
    ORR     R1, R1, #AF7_SELECT     
    STR     R1, [R0]

    LDR     R0, =GPIOA_MODER
    LDR     R1, [R0]
    ORR     R1, R1, #GPIOA_ALT_MODE 
    STR     R1, [R0]

    LDR     R0, =UART2_BRR
    MOVW    R1, #BRR_VALUE
    STR     R1, [R0]

    LDR     R0, =UART2_CR1
    MOV     R1, #CR1_CONFIG
    STR     R1, [R0]

    LDR     R0, =UART2_CR2
    MOV     R1, #CR2_CONFIG
    STR     R1, [R0]

    LDR     R0, =UART2_CR3
    MOV     R1, #CR3_CONFIG
    STR     R1, [R0]

    LDR     R0, =UART2_CR1
    LDR     R1, [R0]
    ORR     R1, R1, #UART_ENABLE
    STR     R1, [R0]

    BX      LR

UART_WriteChar
    LDR     R1, =UART2_SR
wait_tx_ready
    LDR     R2, [R1]
    ANDS    R2, R2, #TXE_FLAG
    BEQ     wait_tx_ready

    LDR     R1, =UART2_DR
    STR     R0, [R1]
    BX      LR

ALIGN
END
