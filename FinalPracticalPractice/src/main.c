#include "stm32f0xx.h"
#include <math.h>
#include <stdint.h>
#define SAMPLES 100
uint16_t array[SAMPLES];

void setfreq(float fre)
{
   // All of the code for this exercise will be written here.
    for(int x=0; x < SAMPLES; x += 1){
        array[x] = 2048 + 1952 * sin(2 * M_PI * x / SAMPLES);
	}

    //step 3 TIM6 setup
    RCC->APB1ENR |= RCC_APB1ENR_TIM6EN;
    TIM6->PSC = 1-1;
    TIM6->ARR = (48000000/(SAMPLES*fre))-1;
    TIM6->CR2 &= ~TIM_CR2_MMS;
    TIM6->CR2 |= TIM_CR2_MMS_1;
    TIM6->CR1 |= TIM_CR1_CEN;
    TIM6->DIER |= TIM_DIER_UDE;

    //step 4 SETUP DMA
    RCC->AHBENR |= RCC_AHBENR_DMA1EN;
    DMA1_Channel3->CMAR = array;
    DMA1_Channel3->CPAR = &(DAC->DHR12R1);
    DMA1_Channel3->CNDTR = SAMPLES;
    DMA1_Channel3->CCR |= DMA_CCR_DIR;
    DMA1_Channel3->CCR |= DMA_CCR_MINC;
    DMA1_Channel3->CCR &= ~DMA_CCR_MSIZE;
    DMA1_Channel3->CCR &= ~DMA_CCR_PSIZE;
    DMA1_Channel3->CCR |= DMA_CCR_MSIZE_0;
    DMA1_Channel3->CCR |= DMA_CCR_PSIZE_0;
    DMA1_Channel3->CCR |= DMA_CCR_CIRC;
    DMA1_Channel3->CCR |= DMA_CCR_EN;

    //Setup DAC
    RCC->APB1ENR |= RCC_APB1ENR_DACEN;
    DAC->CR &= ~DAC_CR_TSEL1;
    DAC->CR |= DAC_CR_TEN1;
    DAC->CR |= DAC_CR_EN1;
    //DAC->CR |= DAC_CR_DMAEN1;
}

int main(void)
{
    // Uncomment any one of the following calls ...
    setfreq(1920.81);
    //setfreq(1234.5);
    //setfreq(8529.48);
    //setfreq(11039.274);
    //setfreq(92816.14);
}
