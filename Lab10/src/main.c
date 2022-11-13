/**
  ******************************************************************************
  * @file    main.c
  * @author  Ac6
  * @version V1.0
  * @date    01-December-2013
  * @brief   Default main function.
  ******************************************************************************
*/


#include "stm32f0xx.h"
			

void init_usart5(void){
    RCC->AHBENR |= RCC_AHBENR_GPIOCEN;
    RCC->AHBENR |= RCC_AHBENR_GPIODEN;

    GPIOC->MODER &= ~GPIO_MODER_MODER12;
    GPIOD->MODER &= ~GPIO_MODER_MODER2;

    GPIOC->MODER |= GPIO_MODER_MODER12_1;
    GPIOD->MODER |= GPIO_MODER_MODER2_1;

    GPIOC->AFR[1] &= ~GPIO_AFRH_AFR12;
    GPIOC->AFR[1] |= 1<<17;
    GPIOD->AFR[0] &= ~GPIO_AFRL_AFR2;
    GPIOD->AFR[0] |= 1<<9;

    RCC->APB1ENR |= RCC_APB1ENR_USART5EN;
    USART5->CR1 &= ~USART_CR1_UE;


    USART5->CR1 &= ~1<<28;
    USART5->CR1 &= ~1<<12;

    USART5->CR2 &= ~USART_CR2_STOP;

    USART5->CR1 &= ~USART_CR1_OVER8;

    USART5->BRR = 0x1A1;

    USART5->CR1 |= USART_CR1_RE;
    USART5->CR1 |= USART_CR1_TE;
    USART5->CR1 |= USART_CR1_UE;

   while(!(USART5->ISR & USART_ISR_TEACK)){}

   while(!(USART5->ISR & USART_ISR_REACK)){}
}






//#define STEP21
#if defined(STEP21)
int main(void)
{
    init_usart5();
    for(;;) {
    while (!(USART5->ISR & USART_ISR_RXNE)) { }
    char c = USART5->RDR;
    while(!(USART5->ISR & USART_ISR_TXE)) { }
    USART5->TDR = c;
    }
}
#endif

#define STEP22
#if defined(STEP22)
#include <stdio.h>
int __io_putchar(int c) {
    if(c == '\n'){
        while(!(USART5->ISR & USART_ISR_TXE));
        USART5->TDR = '\r';

    }
    while(!(USART5->ISR & USART_ISR_TXE));
    USART5->TDR = c;
    return c;
}

int __io_getchar(void) {
    char c = USART5->RDR;
    if(c=='\r'){
        c = '\n';
    }
    __io_putchar(c);
    return c;
}

int main() {
    init_usart5();
    setbuf(stdin,0);
    setbuf(stdout,0);
    setbuf(stderr,0);
    printf("Enter your name: ");
    char name[80];
    fgets(name, 80, stdin);
    printf("Your name is %s", name);
    printf("Type any characters.\n");
    for(;;) {
        char c = getchar();
        putchar(c);
    }
}
#endif

