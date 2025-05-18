#include "stm32f4xx.h"

#define ONESEC_DELAY 5333333  

void UART2_Init(void);
void UART2_WriteChar(char ch);
char UART2_ReadChar(void);
void Delay(volatile uint32_t count);
void LED_Blink(char ch);

int main(void) {
    UART2_Init();

    while (1) {
        char rx_char = UART2_ReadChar(); 
        LED_Blink(rx_char);              
        UART2_WriteChar('Y');           
    }
}

void UART2_Init(void) {
    RCC->AHB1ENR |= RCC_AHB1ENR_GPIOAEN;
    RCC->APB1ENR |= RCC_APB1ENR_USART2EN;

    GPIOA->MODER &= ~((3U << (2 * 2)) | (3U << (3 * 2)));  
    GPIOA->MODER |=  (2U << (2 * 2)) | (2U << (3 * 2));    

    GPIOA->AFR[0] |= (7U << (2 * 4)) | (7U << (3 * 4));

    GPIOA->MODER &= ~(3U << (5 * 2)); 
    GPIOA->MODER |=  (1U << (5 * 2));  

    USART2->BRR = 0x0683;
    USART2->CR1 = USART_CR1_TE | USART_CR1_RE; 
    USART2->CR1 |= USART_CR1_UE;             
}

void UART2_WriteChar(char ch) {
    while (!(USART2->SR & USART_SR_TXE));  
    USART2->DR = (ch & 0xFF);
}

char UART2_ReadChar(void) {
    while (!(USART2->SR & USART_SR_RXNE));  
    return USART2->DR & 0xFF;
}

void Delay(volatile uint32_t count) {
    while (count--);
}

void LED_Blink(char ch) {
    if (ch == '1') {
        GPIOA->BSRR = (1U << 5);   
        Delay(ONESEC_DELAY);
        GPIOA->BSRR = (1U << (5 + 16));  
        Delay(ONESEC_DELAY);
    }
}
