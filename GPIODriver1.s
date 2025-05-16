    AREA |.text|, CODE, READONLY, ALIGN=2
    THUMB
    ENTRY

    EXPORT __main

RCC_BASE            EQU     0x40023800
GPIOA_BASE          EQU     0x40020000

RCC_AHB1ENR         EQU     RCC_BASE + 0x30
GPIOA_MODER         EQU     GPIOA_BASE + 0x00
GPIOA_ODR           EQU     GPIOA_BASE + 0x14

GPIOA_EN            EQU     (1 << 0)
MODER5_CLEAR_MASK   EQU     ~(0x3 << 10)
MODER5_OUTPUT       EQU     (0x1 << 10)
LED_ON              EQU     (1 << 5)

__main
    BL GPIOA_Init

loop
    B loop

GPIOA_Init
    ; Enable GPIOA clock
    LDR R0, =RCC_AHB1ENR
    LDR R1, [R0]
    ORR R1, R1, 
    STR R1, [R0]

    ; Set PA5 as output (01)
    LDR R0, =GPIOA_MODER
    LDR R1, [R0]
    BIC R1, R1, 
    ORR R1, R1,
    STR R1, [R0]

    ; Set PA5 high (turn on LED)
    LDR R0, =GPIOA_ODR
    LDR R1, [R0]
    ORR R1, R1, 
    STR R1, [R0]

    BX LR

    ALIGN
    END
