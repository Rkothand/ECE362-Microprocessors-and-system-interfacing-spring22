
#include "stm32f0xx.h"
#include <string.h> // for memcpy() declaration

void nano_wait(unsigned int);
extern const char font[128];

//===========================================================================
// Debouncing a Keypad
//===========================================================================

void drive_column(int);
int read_rows();
void update_history(col, rows);

uint8_t col;
void TIM7_IRQHandler(void) {
    TIM7->SR &= ~TIM_SR_UIF;
    int rows = read_rows();
    update_history(col, rows);
    col = (col + 1) & 3;
    drive_column(col);
}

void init_tim7() {
    RCC->APB1ENR |= RCC_APB1ENR_TIM7EN;
    TIM7->DIER |= TIM_DIER_UIE;
    TIM7->PSC = 4800-1;
    TIM7->ARR =10-1;
    TIM7->CR1 |=TIM_CR1_CEN;
    NVIC->ISER[0] =1<<TIM7_IRQn;
}

//===========================================================================
// SPI DMA LED Array
//===========================================================================
uint16_t msg[8] = { 0x0000,0x0100,0x0200,0x0300,0x0400,0x0500,0x0600,0x0700 };

void init_spi2(void) {
    RCC->AHBENR|= RCC_AHBENR_GPIOBEN;
    RCC->APB1ENR |= RCC_APB1ENR_SPI2EN;

    GPIOB->MODER &= ~GPIO_MODER_MODER12;
    GPIOB->MODER &= ~GPIO_MODER_MODER13;
    GPIOB->MODER &= ~GPIO_MODER_MODER15;

    GPIOB->MODER |= GPIO_MODER_MODER12_1;
    GPIOB->MODER |= GPIO_MODER_MODER13_1;
    GPIOB->MODER |= GPIO_MODER_MODER15_1;
    GPIOB->AFR[1] &= ~GPIO_AFRH_AFR12;
    GPIOB->AFR[1] &= ~GPIO_AFRH_AFR13;
    GPIOB->AFR[1] &= ~GPIO_AFRH_AFR15;

    SPI2->CR1 &= ~SPI_CR1_SPE;
    SPI2->CR1 |= SPI_CR1_BR;

    SPI2->CR2 |= SPI_CR2_DS;

    SPI2->CR1 |= SPI_CR1_MSTR;

    SPI2-> CR2 |= SPI_CR2_NSSP;

    SPI2-> CR2 |= SPI_CR2_TXDMAEN;

    SPI2->CR1 |= SPI_CR1_SPE;
}

void setup_dma(void)
{
    RCC->AHBENR |= RCC_AHBENR_DMAEN;
    DMA1_Channel5->CPAR = &SPI2->DR;
    DMA1_Channel5->CMAR = (uint32_t) msg;
    DMA1_Channel5->CNDTR = 8;
    DMA1_Channel5->CCR |= DMA_CCR_DIR;
    DMA1_Channel5->CCR |= DMA_CCR_MINC;
    DMA1_Channel5->CCR &= ~DMA_CCR_MSIZE;
    DMA1_Channel5->CCR |= DMA_CCR_MSIZE_0;
    DMA1_Channel5->CCR &= ~DMA_CCR_PSIZE;
    DMA1_Channel5->CCR |= DMA_CCR_PSIZE_0;
    DMA1_Channel5->CCR |= DMA_CCR_CIRC;
}

void enable_dma(void)
{
    DMA1_Channel5->CCR |= DMA_CCR_EN;
}

void setup_spi2_dma(void) {
    setup_dma();
    SPI2->CR2 |= SPI_CR2_TXDMAEN;// Transfer register empty DMA enable
}

void enable_spi2_dma(void) {
    enable_dma();
}

//===========================================================================
// 2.1 Initialize I2C
//===========================================================================
#define GPIOEX_ADDR 0x20  // ENTER GPIO EXPANDER I2C ADDRESS HERE
#define EEPROM_ADDR 0x50  // ENTER EEPROM I2C ADDRESS HERE

void init_i2c(void) {
    RCC->AHBENR |= RCC_AHBENR_GPIOBEN;
    RCC->APB1ENR |= RCC_APB1ENR_I2C1EN;
    GPIOB->MODER |= GPIO_MODER_MODER7_1 | GPIO_MODER_MODER6_1;
    GPIOB->AFR[0] |= 1<<(4*6) | 1<<(4*7);

    I2C1->CR1 &= ~I2C_CR1_PE;
    I2C1->CR1 &= ~I2C_CR1_ANFOFF;
    I2C1->CR1 &= ~I2C_CR1_ERRIE;
    I2C1->CR1 &= ~I2C_CR1_NOSTRETCH;

    I2C1->TIMINGR =0;
    I2C1->TIMINGR &= ~I2C_TIMINGR_PRESC;
    I2C1->TIMINGR |= 0 << 28;
    I2C1->TIMINGR |= 3 << 20;
    I2C1->TIMINGR |= 1 <<16;
    I2C1->TIMINGR |= 3 << 8;
    I2C1->TIMINGR |= 9 << 0;

    I2C1->OAR1 &= ~I2C_OAR1_OA1EN;
    //I2C1->OAR1 = I2C_OAR1_OA1EN | 0x2;
    I2C1->OAR1 &= ~I2C_OAR2_OA2EN;

    I2C1->CR2 &= ~I2C_CR2_ADD10;
    I2C1->CR2 |= I2C_CR2_AUTOEND;
    //I2C1->CR2 |= I2C_CR2_NACK;

    I2C1->CR1 |= I2C_CR1_PE;
}


//===========================================================================
// 2.2 I2C helpers
//===========================================================================

void i2c_waitidle(void) { //check
    while((I2C1->ISR & I2C_ISR_BUSY) == I2C_ISR_BUSY);
}

void i2c_start(uint32_t devaddr, uint8_t size, uint8_t dir) {
    uint32_t tmpreg = I2C1->CR2;
    tmpreg &= ~(I2C_CR2_SADD | I2C_CR2_NBYTES | I2C_CR2_RELOAD | I2C_CR2_AUTOEND | I2C_CR2_RD_WRN | I2C_CR2_START | I2C_CR2_STOP);
    if(dir==1)
        tmpreg |= I2C_CR2_RD_WRN;
    else
        tmpreg &= ~I2C_CR2_RD_WRN;

    tmpreg |= ((devaddr<<1) & I2C_CR2_SADD) | ((size <<16) & I2C_CR2_NBYTES);
    tmpreg |= I2C_CR2_START;
    I2C1->CR2 = tmpreg;

}

void i2c_stop(void) {
    if (I2C1->ISR & I2C_ISR_STOPF)
        return;
    I2C1->CR2 |= I2C_CR2_STOP;
    while((I2C1->ISR & I2C_ISR_STOPF)==0);
    I2C1->ICR |= I2C_ICR_STOPCF;
}

int i2c_checknack(void) {
    int check = I2C1->ISR;
    check &= I2C_ISR_NACKF;
    int out;
    if(check == 1<<4){
        out = 1;
        return out;
    }
    else{
        out = 0;
        return out;
    }
    /*
    if((I2C1->ISR & I2C_ISR_NACKF))
        return 1;
    else
        return 0;
        */
}

void i2c_clearnack(void) {
    I2C1->ICR |= I2C_ICR_NACKCF;
}

int i2c_senddata(uint8_t devaddr, const void *data, uint8_t size) {
    int i;
    if(size<= 0|| data ==0) return -1;
    uint8_t *udata = (uint8_t*)data;
    i2c_waitidle();
    i2c_start(devaddr, size, 0);

    for(i=0; i<size; i++){
        int count =0;
        while((I2C1->ISR & I2C_ISR_TXIS) ==0){
            count += 1;
            if(count > 1000000) return -1;
            if(i2c_checknack()){
                i2c_clearnack();
                i2c_stop();
                return-1;
            }
        }
        I2C1->TXDR = udata[i] & I2C_TXDR_TXDATA;
    }
    while((I2C1->ISR & I2C_ISR_TC)==0 && (I2C1->ISR & I2C_ISR_NACKF) == 0);
    if((I2C1->ISR &I2C_ISR_NACKF) != 0)
        return -1;
    i2c_stop();
    return 0;

}

int i2c_recvdata(uint8_t devaddr, void *data, uint8_t size) {
    int i;
    if(size <=0 || data ==0) return -1;
    uint8_t *udata = (uint8_t*)data;
    i2c_waitidle();
    i2c_start(devaddr,size,1);
    for(i=0; i<size; i++){
        int count = 0;
        while((I2C1->ISR & I2C_ISR_RXNE) == 0){
            count += 1;
            if (count>1000000) return -1;
            if(i2c_checknack()){
                i2c_clearnack();
                i2c_stop();
                return-1;
            }
        }
        udata[i] =I2C1->RXDR;
    }
    while((I2C1->ISR & I2C_ISR_TC)==0 && (I2C1->ISR & I2C_ISR_NACKF)==0);
    if((I2C1->ISR & I2C_ISR_NACKF) != 0)
        return -1;
    i2c_stop();
    return 0;

}


//===========================================================================
// 2.4 GPIO Expander
//===========================================================================
void gpio_write(uint8_t reg, uint8_t val) {
   int arr[2] = {reg,val};
   i2c_senddata(EEPROM_ADDR, arr, sizeof(arr));
}

uint8_t gpio_read(uint8_t reg) {
    int arr[1] = {reg};
    i2c_senddata(EEPROM_ADDR, arr, sizeof(arr));
    i2c_recvdata(EEPROM_ADDR, arr, sizeof(arr));
}

void init_expander(void) {
    void gpio_write(uint8_t reg, uint8_t value);

}

void drive_column(int c) {
    gpio_write(10, ~(1 << (3 - c)) );
}

int read_rows() {
    uint8_t data = gpio_read(9);
    data &= 0xf0;
    for (int i = 0; i < 4; i++) {
        uint8_t bit = data & (1 << (4 + i));
        bit >>= (4 + i);
        bit <<= (3 - i);
        data |= bit;
    }
    return data & 0xf;
}

//===========================================================================
// 2.4 EEPROM functions
//===========================================================================
void eeprom_write(uint16_t loc, const char* data, uint8_t len) {
}

int eeprom_write_complete(void) {
}

void eeprom_read(uint16_t loc, char data[], uint8_t len) {
    TIM7->CR1 &= ~TIM_CR1_CEN; // Pause keypad scanning.

    // ... your code here

    TIM7->CR1 |= TIM_CR1_CEN; // Resume keypad scanning.
}


void eeprom_blocking_write(uint16_t loc, const char* data, uint8_t len) {
    TIM7->CR1 &= ~TIM_CR1_CEN; // Pause keypad scanning.
    eeprom_write(loc, data, len);
    while (!eeprom_write_complete());
    TIM7->CR1 |= TIM_CR1_CEN; // Resume keypad scanning.
}

//===========================================================================
// Main and supporting functions
//===========================================================================

void serial_ui(void);
void show_keys(void);

int main(void)
{
    msg[0] |= font['E'];
    msg[1] |= font['C'];
    msg[2] |= font['E'];
    msg[3] |= font[' '];
    msg[4] |= font['3'];
    msg[5] |= font['6'];
    msg[6] |= font['2'];
    msg[7] |= font[' '];


    // LED array SPI
    setup_spi2_dma();
    enable_spi2_dma();
    init_spi2();

    // This LAB

    // 2.1 Initialize I2C
    init_i2c();

    // 2.2 Example code for testing
//#define STEP22
#if defined(STEP22)
    for(;;) {
        i2c_waitidle();
        i2c_start(GPIOEX_ADDR,0,0);
        i2c_clearnack();
        i2c_stop();
    }
#endif

    // 2.3 Example code for testing
#define STEP23
#if defined(STEP23)
    for(;;) {
        uint8_t data[2] = { 0x00, 0xff };
        i2c_senddata(0x20, data, 2);
    }
#endif

    // 2.4 Expander setup
    init_expander();
    init_tim7();

    // 2.5 Interface for reading/writing memory.
    serial_ui();

    show_keys();
}

