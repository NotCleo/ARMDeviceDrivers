AREA |.text|, CODE, READONLY
THUMB
ENTRY
EXPORT __main

UART2_BASE    EQU 0x40004400
USART_SR      EQU UART2_BASE + 0x00
USART_DR      EQU UART2_BASE + 0x04
USART_BRR     EQU UART2_BASE + 0x08
USART_CR1     EQU UART2_BASE + 0x0C

NVIC_ISER1    EQU 0xE000E104  
USART2_IRQN   EQU 38

TXE_FLAG      EQU 1 << 7
TE            EQU 1 << 3
UE            EQU 1 << 13
TXEIE         EQU 1 << 7

__main
    BL UART_Init

    MOV R0, #'H'
    BL UART_Send_Char_IT

loop
    B loop

UART_Init
    LDR R0, =USART_BRR
    MOV R1, #0x0683  
    STR R1, [R0]

    LDR R0, =USART_CR1
    MOV R1, #(TE | UE | TXEIE)
    STR R1, [R0]

    LDR R0, =NVIC_ISER1
    MOV R1, #(1 << (USART2_IRQN - 32))
    STR R1, [R0]

    BX LR

UART_Send_Char_IT
    ; Assumes R0 has data to send
    LDR R1, =USART_DR
    STR R0, [R1]
    BX LR

EXPORT USART2_IRQHandler
USART2_IRQHandler
    LDR R0, =USART_SR
    LDR R1, [R0]
    TST R1, #TXE_FLAG
    BEQ end_irq

    MOV R2, #'i'
    LDR R3, =USART_DR
    STR R2, [R3]

    LDR R4, =USART_CR1
    LDR R5, [R4]
    BIC R5, R5, #TXEIE
    STR R5, [R4]

end_irq
    BX LR
