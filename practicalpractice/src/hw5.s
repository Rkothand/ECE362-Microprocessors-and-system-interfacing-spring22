.cpu cortex-m0
.thumb
.syntax unified
.fpu softvfp

.equ RCC,       0x40021000
.equ GPIOA,     0x48000000
.equ GPIOB,     0x48000400
.equ GPIOC,     0x48000800
.equ AHBENR,    0x14
.equ APB2ENR,   0x18
.equ APB1ENR,   0x1c
.equ IOPAEN,    0x20000
.equ IOPBEN,    0x40000
.equ IOPCEN,    0x80000
.equ SYSCFGCOMPEN, 1
.equ TIM3EN,    2
.equ MODER,     0
.equ OSPEEDR,   8
.equ PUPDR,     0xc
.equ IDR,       0x10
.equ ODR,       0x14
.equ BSRR,      0x18
.equ BRR,       0x28
.equ PC8,       0x100

// SYSCFG control registers
.equ SYSCFG,    0x40010000
.equ EXTICR1,   0x8
.equ EXTICR2,   0xc
.equ EXTICR3,   0x10
.equ EXTICR4,   0x14

// NVIC control registers
.equ NVIC,      0xe000e000
.equ ISER,      0x100

// External interrupt control registers
.equ EXTI,      0x40010400
.equ IMR,       0x00
.equ RTSR,      0x08
.equ PR,        0x14

.equ TIM3,      0x40000400
.equ TIMCR1,    0x00
.equ DIER,      0x0c
.equ TIMSR,     0x10
.equ PSC,       0x28
.equ ARR,       0x2c

// Popular interrupt numbers
.equ EXTI0_1_IRQn,   5
.equ EXTI2_3_IRQn,   6
.equ EXTI4_15_IRQn,  7
.equ EXTI4_15_IRQn,  7
.equ TIM2_IRQn,      15
.equ TIM3_IRQn,      16
.equ TIM6_DAC_IRQn,  17
.equ TIM7_IRQn,      18
.equ TIM14_IRQn,     19
.equ TIM15_IRQn,     20
.equ TIM16_IRQn,     21
.equ TIM17_IRQn,     22

//====================================================================
// Q1
//====================================================================
.global recur
recur:
push {LR}
cmp r0, #3
bcs recurif2

recurif1:
b recurdone

recurif2:
ldr r1, =0xf
ands r1, r0
cmp r1, #0
bne recurelse

subs r0, #1
bl recur
adds r0, #1
b recurdone

recurelse:
lsrs r0, r0, #1
bl recur
adds r0, #2

recurdone:

pop {PC}
//====================================================================
// Q2
//====================================================================
.global enable_portb
enable_portb:
push {LR}
ldr r0, =RCC
ldr r1, [r0, #AHBENR]
ldr r2, =IOPBEN
orrs r1, r2
str r1, [r0, #AHBENR]
pop {PC}

//====================================================================
// Q3
//====================================================================
.global enable_portc
enable_portc:
push {LR}
ldr r0, =RCC
ldr r1, [r0, #AHBENR]
ldr r2, =IOPCEN
orrs r1, r2
str r1, [r0, #AHBENR]
pop {PC}

//====================================================================
// Q4
//====================================================================
.global setup_pb3
setup_pb3:
push {LR}
ldr r0, =GPIOB
ldr r1, [r0, #MODER]
ldr r2, =0xC0
bics r1, r2
str r1, [r0, #MODER]

ldr r1, [r0, #PUPDR]
ldr r2, =0xC0
bics r1, r2
ldr r2, =0x80
orrs r1, r2
str r1, [r0, #PUPDR]
pop {PC}
//====================================================================
// Q5
//====================================================================
.global setup_pb4
setup_pb4:
push {LR}
ldr r0, =GPIOB
ldr r1, [r0, #MODER]
ldr r2, =0x300
bics r1, r2
str r1, [r0, #MODER]

ldr r1, [r0, #PUPDR]
ldr r2, =0x300
bics r1, r2
str r1, [r0, #PUPDR]
pop {PC}

//====================================================================
// Q6
//====================================================================
.global setup_pc8
setup_pc8:
push {LR}
ldr r0, =GPIOC
ldr r1, [r0, #MODER]
ldr r2, =0x30000
bics r1, r2
ldr r2, =0x10000
orrs r1, r2
str r1, [r0, #MODER]

ldr r0, =GPIOC
ldr r1, [r0, #OSPEEDR]
ldr r2, =0x30000
bics r1, r2
ldr r2, =0x30000
orrs r1, r2
str r1, [r0, #OSPEEDR]
pop {PC}
//====================================================================
// Q7
//====================================================================
.global setup_pc9
setup_pc9:
push {LR}
ldr r0, =GPIOC
ldr r1, [r0, #MODER]
ldr r2, =0xC0000
bics r1, r2
ldr r2, =0x40000
orrs r1, r2
str r1, [r0, #MODER]

ldr r0, =GPIOC
ldr r1, [r0, #OSPEEDR]
ldr r2, =0xC0000
bics r1, r2
ldr r2, =0x40000
orrs r1, r2
str r1, [r0, #OSPEEDR]
pop {PC}

//====================================================================
// Q8
//====================================================================
.global action8
action8:
push {LR}
ldr r0, =GPIOB
ldr r1, [r0, #IDR]
ldr r2, =0xFFE7
bics r1, r2
ldr r2, =0x0008
cmp r1,r2
bne action8iffalse

action8iftrue:
ldr r0, =GPIOC
ldr r1, =0x100
str r1, [r0, #BRR]
b action8done

action8iffalse:
ldr r0, =GPIOC
ldr r1, =0x100
str r1, [r0, #BSRR]

action8done:
pop {PC}
//====================================================================
// Q9
//====================================================================
.global action9
action9:
push {LR}
ldr r0, =GPIOB
ldr r1, [r0, #IDR]
ldr r2, =0xFFE7
bics r1, r2
ldr r2, =0x0010
cmp r1,r2
bne action9iffalse

action9iftrue:
ldr r0, =GPIOC
ldr r1, =0x200
str r1, [r0, #BSRR]
b action8done

action9iffalse:
ldr r0, =GPIOC
ldr r1, =0x200
str r1, [r0, #BRR]

action9done:
pop {PC}//====================================================================
// Q10
//====================================================================
// Do everything needed to write the ISR here...
.type EXTI2_3_IRQHandler %function
.global EXTI2_3_IRQHandler
EXTI2_3_IRQHandler:
push {LR}
ldr r0, =EXTI
//ldr r1, [r0, #PR]
//ldr r2, =0x4
//orrs r1, r2
//ldr r1, =0xC

ldr r1, =0x4
str r1, [r0, #PR]

ldr r0, =counter
ldr r3, [r0]
adds r3, #1
str r3, [r0]
pop {PC}
//====================================================================
// Q11
//====================================================================
.global enable_exti
enable_exti:
push {LR}
ldr r0, =RCC
ldr r1, [r0,# APB2ENR]
ldr r2, =SYSCFGCOMPEN
orrs r1, r2
str r1, [r0,# APB2ENR]

ldr r0, =SYSCFG
ldr r1, [r0, #EXTICR1]
ldr r2, =0xF00
bics r1, r2
ldr r2, =0x100
orrs r1, r2
str r1, [r0, #EXTICR1]

ldr r0, =EXTI
ldr r1, [r0, #RTSR]
ldr r2, =0x4
orrs r1, r2
str r1, [r0, #RTSR]

ldr r0, =EXTI
ldr r1, [r0, #IMR]
ldr r2, =0x4
orrs r1, r2
str r1, [r0, #IMR]

ldr r0, =NVIC
ldr r3, =ISER
ldr r1, [r0, r3]
ldr r2, =1<<6
orrs r1, r2
str r1, [r0, r3]


pop {PC}
//====================================================================
// Q12
//====================================================================
// Do everything needed to write the ISR here...
.type TIM3_IRQHandler %function
.global TIM3_IRQHandler
TIM3_IRQHandler:
push {LR}
ldr r0, =TIM3
ldr r1, [r0, #TIMSR]
ldr r2, =0x1
bics r1,r2
str r1, [r0, #TIMSR]

ldr r0, =GPIOC
ldr r1, [r0, #ODR]
ldr r2, =0xFDFF
bics r1, r2
ldr r2, =1<<9
cmp r1, r2
bne irqelse1

irqif1:
str r2, [r0, #BRR]
b irqdone1
irqelse1:
str r2, [r0, #BSRR]
irqdone1:
pop {PC}
//====================================================================
// Q13
//====================================================================
.global enable_tim3
enable_tim3:
push {LR}
ldr r0, =RCC
ldr r1, [r0, #APB1ENR]
ldr r2, =1<<1
orrs r1, r2
str r1, [r0, #APB1ENR]

ldr r0, =TIM3
ldr r1, =999
str r1, [r0, #ARR]

ldr r1, =11999
str r1, [r0, #PSC]

ldr r1, [r0, #DIER]
ldr r2, =0x1
orrs r1, r2
str r1, [r0, #DIER]

ldr r0, =NVIC
ldr r3, =ISER
ldr r1, [r0, r3]
ldr r2, =1<<TIM3_IRQn
orrs r1, r2
str r1, [r0, r3]

ldr r0, =TIM3
ldr r3, =TIMCR1
ldr r1, [r0, r3]
ldr r2, =0x1
orrs r1, r2
str r1, [r0, r3]
pop {PC}

