#include "stm32f0xx.h"
#include "lcd.h"

void init_lcd_spi(void)
{
//Enable the RCC clock to GPIO Port B
RCC->AHBENR |= RCC_AHBENR_GPIOBEN;

// Set PB8, PB11, and PB14 to be outputs
GPIOB->MODER &= ~ GPIO_MODER_MODER8;
GPIOB->MODER &= ~ GPIO_MODER_MODER11;
GPIOB->MODER &= ~ GPIO_MODER_MODER14;

GPIOB->MODER |= GPIO_MODER_MODER8_0;
GPIOB->MODER |= GPIO_MODER_MODER11_0;
GPIOB->MODER |= GPIO_MODER_MODER14_0;

//Set the ODR value for PB8, PB11, and PB14 to be 1 (logic high)
GPIOB->BSRR |= 1<<8;
GPIOB->BSRR |= 1<11;
GPIOB->BSRR |= 1<14;

// Configure PB3 to be alternate function 0
GPIOB->MODER &= ~ GPIO_MODER_MODER3;
GPIOB->MODER |= GPIO_MODER_MODER3_1;
//GPIOB->AFR[0]|=GPIO_AFRL_AFR3;


// Configure PB5 to be alternate function 0
GPIOB->MODER &= ~ GPIO_MODER_MODER5;
GPIOB->MODER |= GPIO_MODER_MODER5_1;
//GPIOB->AFR[0]|=GPIO_AFRL_AFR5;

// Enable the RCC clock to SPI1
RCC->APB2ENR |= RCC_APB2ENR_SPI1EN;

//Turn off the SPI1 peripheral (clear the SPE bit)
SPI1->CR1 &= ~SPI_CR1_SPE;

// Set the baud rate to be as high as possible
SPI1->CR1 &= ~SPI_CR1_BR;

// Configure the SPI1 peripheral for "master mode"
SPI1->CR1 |= SPI_CR1_MSTR;

//Set the word size to be 8-bit
SPI1->CR2 &= ~SPI_CR2_DS;

// Set the SSM and SSI bits
SPI1->CR1 |= SPI_CR1_SSM;
SPI1->CR1 |= SPI_CR1_SSI;

// Enable the SPI1 peripheral (set the SPE bit)
SPI1->CR1 |= SPI_CR1_SPE;

}

void setup_buttons(void){
    //Enables the RCC clock to GPIOB and GPIOC without affecting any other RCC clock settings for other peripherals

    RCC->AHBENR |= RCC_AHBENR_GPIOCEN;
    //Configures pins PB0 – PB10 to be outputs


    //Configures pins PC4 – PC7 to be outputs
    GPIOC->MODER &= ~ GPIO_MODER_MODER4;
    GPIOC->MODER &= ~ GPIO_MODER_MODER5;
    GPIOC->MODER &= ~ GPIO_MODER_MODER6;
    GPIOC->MODER &= ~ GPIO_MODER_MODER7;

    GPIOC->MODER |= GPIO_MODER_MODER4_0;
    GPIOC->MODER |= GPIO_MODER_MODER5_0;
    GPIOC->MODER |= GPIO_MODER_MODER6_0;
    GPIOC->MODER |= GPIO_MODER_MODER7_0;

    //Configures pins PC0 – PC3 to be inputs
    GPIOC->MODER &= ~GPIO_MODER_MODER0;
    GPIOC->MODER &= ~GPIO_MODER_MODER1;
    GPIOC->MODER &= ~GPIO_MODER_MODER2;
    GPIOC->MODER &= ~GPIO_MODER_MODER3;

    //Configures pins PC4 – PC7 to have output type open-drain (using the OTYPER)
    GPIOC->OTYPER |= GPIO_OTYPER_OT_4;
    GPIOC->OTYPER |= GPIO_OTYPER_OT_5;
    GPIOC->OTYPER |= GPIO_OTYPER_OT_6;
    GPIOC->OTYPER |= GPIO_OTYPER_OT_7;

    //Configures pins PC0 – PC3 to be internally pulled high

    GPIOC->PUPDR &= ~GPIO_PUPDR_PUPDR0;
    GPIOC->PUPDR &= ~GPIO_PUPDR_PUPDR1;
    GPIOC->PUPDR &= ~GPIO_PUPDR_PUPDR2;
    GPIOC->PUPDR &= ~GPIO_PUPDR_PUPDR3;

    GPIOC->PUPDR |= GPIO_PUPDR_PUPDR0_0;
    GPIOC->PUPDR |= GPIO_PUPDR_PUPDR1_0;
    GPIOC->PUPDR |= GPIO_PUPDR_PUPDR2_0;
    GPIOC->PUPDR |= GPIO_PUPDR_PUPDR3_0;
}


void basic_drawing(void);
void move_ball(void);

int main(void)
{
    setup_buttons();
    LCD_Setup(); // this will call init_lcd_spi()
    basic_drawing();
    move_ball();
}

