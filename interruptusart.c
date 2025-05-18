#define USART2_BASE   0x40004400
#define USART_SR   (*(volatile uint32_t*)(USART2_BASE + 0x00))
#define USART_DR   (*(volatile uint32_t*)(USART2_BASE + 0x04))
#define USART_BRR  (*(volatile uint32_t*)(USART2_BASE + 0x08))
#define USART_CR1  (*(volatile uint32_t*)(USART2_BASE + 0x0C))

#define NVIC_ISER1 (*(volatile uint32_t*)0xE000E104)

#define USART2_IRQN 38

volatile char tx_buffer[] = "man this was so tiring to code lol";
volatile int tx_index = 0;

void UART_Init(void) 
{
    USART_BRR = 0x0683;              
    USART_CR1 |= (1 << 3);            
    USART_CR1 |= (1 << 13);          
    USART_CR1 |= (1 << 7);           
    NVIC_ISER1 |= (1 << (USART2_IRQN - 32)); 
}

void UART_Send_Char_IT(char c) {
    USART_DR = c;
}

void USART2_IRQHandler(void) 
{
    if (USART_SR & (1 << 7)) 
    { 
        tx_index++;
        if (tx_buffer[tx_index] != '\0') 
        {
            USART_DR = tx_buffer[tx_index];
        } 
        else 
        {
            USART_CR1 &= ~(1 << 7);
        }
    }
}

int main(void) 
{
    UART_Init();
    UART_Send_Char_IT(tx_buffer[0]);
    while (1);
}
