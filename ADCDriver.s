        AREA RESET, DATA, READONLY
        ENTRY

        LDR R0, =RCC_AHB1ENR
        LDR R1, =GPIOA_EN
        LDR R2, [R0]
        ORR R2, R2, R1
        STR R2, [R0]

        LDR R0, =GPIOA_MODER
        LDR R1, [R0]
        ORR R1, R1, #MODER1_ANLG_SLT    
        STR R1, [R0]

        LDR R0, =GPIOA_MODER
        LDR R1, [R0]
        BIC R1, R1, #(0b11 << 4)      
        ORR R1, R1, #(0b10 << 4)      
        STR R1, [R0]

        LDR R0, =GPIOA_BASE + 0x20      
        LDR R1, [R0]
        BIC R1, R1, #(0xF << 8)         
        ORR R1, R1, #(0x7 << 8)        
        STR R1, [R0]

        LDR R0, =RCC_APB1ENR
        LDR R1, =USART2_EN
        LDR R2, [R0]
        ORR R2, R2, R1
        STR R2, [R0]

        ;USART2: 9600baud 
        ;BRR = fclk / baud = 16000000 / 9600 ≈ 1667 = 0x0683
        LDR R0, =USART2_BRR
        MOV R1, #0x683
        STR R1, [R0]

        LDR R0, =USART2_CR1
        MOV R1, #(USART_EN + USART_TE)
        STR R1, [R0]

        LDR R0, =RCC_APB2ENR
        LDR R1, =ADC1_EN
        LDR R2, [R0]
        ORR R2, R2, R1
        STR R2, [R0]

        LDR R0, =ADC1_CR2
        MOV R1, #CR2_CNF
        STR R1, [R0]

        LDR R0, =ADC1_SQR3
        MOV R1, #1
        STR R1, [R0]

main_loop
        LDR R0, =ADC1_CR2
        LDR R1, [R0]
        ORR R1, R1, #CR2_STRT_CNV
        STR R1, [R0]

wait_adc
        LDR R0, =ADC1_SR
        LDR R1, [R0]
        TST R1, #ADC1_SR_FLG
        BEQ wait_adc

        LDR R0, =ADC1_DR
        LDR R1, [R0]           

        BL  print_adc_value

        B main_loop

print_adc_value
        MOV     R2, #1000
        BL      send_digit

        MOV     R2, #100
        BL      send_digit

        MOV     R2, #10
        BL      send_digit

        MOV     R2, #1
        BL      send_digit

        ; Send newline
        MOV     R0, #13
        BL      send_char
        MOV     R0, #10
        BL      send_char
        BX      LR

send_digit

        UDIV    R3, R1, R2     
        MLS     R1, R3, R2, R1 
        ADD     R0, R3, #'0'   
        BL      send_char
        BX      LR
send_char
wait_tx_ready
        LDR     R3, =USART2_SR
        LDR     R4, [R3]
        TST     R4, #USART_TXE
        BEQ     wait_tx_ready
        LDR     R3, =USART2_DR
        STRB    R0, [R3]
        BX      LR

RCC_BASE              EQU     0x40023800
GPIOA_BASE            EQU     0x40020000
ADC1_BASE             EQU     0x40012000
USART2_BASE           EQU     0x40004400

RCC_AHB1ENR           EQU     RCC_BASE + 0x30
RCC_APB2ENR           EQU     RCC_BASE + 0x44
RCC_APB1ENR           EQU     RCC_BASE + 0x40

GPIOA_MODER           EQU     GPIOA_BASE + 0x00
ADC1_SR               EQU     ADC1_BASE + 0x00
ADC1_CR2              EQU     ADC1_BASE + 0x08
ADC1_SQR3             EQU     ADC1_BASE + 0x34
ADC1_DR               EQU     ADC1_BASE + 0x4C

USART2_SR             EQU     USART2_BASE + 0x00
USART2_DR             EQU     USART2_BASE + 0x04
USART2_BRR            EQU     USART2_BASE + 0x08
USART2_CR1            EQU     USART2_BASE + 0x0C

GPIOA_EN              EQU     (1 << 0)
ADC1_EN               EQU     (1 << 8)
MODER1_ANLG_SLT       EQU     (0x3 << 2)

USART2_EN             EQU     (1 << 17)
USART_EN              EQU     (1 << 13)
USART_TE              EQU     (1 << 3)
USART_TXE             EQU     (1 << 7)

ADC1_SR_FLG           EQU     0x2
CR2_CNF               EQU     0x1
CR2_STRT_CNV          EQU     0x40000000
