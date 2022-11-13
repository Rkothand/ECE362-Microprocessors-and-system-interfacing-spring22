.cpu cortex-m0
.thumb
.syntax unified

// RCC configuration registers
.equ  RCC,      0x40021000
.equ  AHBENR,   0x014
.equ  GPIOCEN,  0x080000
.equ  GPIOBEN,  0x040000
.equ  GPIOAEN,  0x020000
.equ  APB1ENR,  0x01c
.equ  TIM6EN,   1<<4
.equ  TIM7EN,   1<<5
.equ  TIM14EN,  1<<8

// NVIC configuration registers
.equ NVIC, 0xe000e000
.equ ISER, 0x0100
.equ ICER, 0x0180
.equ ISPR, 0x0200
.equ ICPR, 0x0280
.equ IPR,  0x0400
.equ TIM6_DAC_IRQn, 17
.equ TIM7_IRQn,     18
.equ TIM14_IRQn,    19

// Timer configuration registers
.equ TIM6,   0x40001000
.equ TIM7,   0x40001400
.equ TIM14,  0x40002000
.equ TIM_CR1,  0x00
.equ TIM_CR2,  0x04
.equ TIM_DIER, 0x0c
.equ TIM_SR,   0x10
.equ TIM_EGR,  0x14
.equ TIM_CNT,  0x24
.equ TIM_PSC,  0x28
.equ TIM_ARR,  0x2c

// Timer configuration register bits
.equ TIM_CR1_CEN,  1<<0
.equ TIM_DIER_UDE, 1<<8
.equ TIM_DIER_UIE, 1<<0
.equ TIM_SR_UIF,   1<<0

// GPIO configuration registers
.equ  GPIOC,    0x48000800
.equ  GPIOB,    0x48000400
.equ  GPIOA,    0x48000000
.equ  MODER,    0x0
.equ  PUPDR,    0xc
.equ  IDR,      0x10
.equ  ODR,      0x14
.equ  BSRR,     0x18
.equ  BRR,      0x28

//============================================================================
// enable_ports() {
// Set up the ports and pins exactly as directed.
// }
.global enable_ports
enable_ports:
push {LR}
ldr r0, =RCC
ldr r1, [r0, #AHBENR]
ldr r2, =GPIOBEN
orrs r1, r2
ldr r2, =GPIOCEN
orrs r1, r2
str r1, [r0, #AHBENR]

ldr r0, =GPIOB
ldr r1, [r0, #MODER]
ldr r2, =0x003FFFFF
bics r1, r2
ldr r2, =0x00155555
orrs r1, r2
str r1, [r0, #MODER]

ldr r0, =GPIOC
ldr r1, [r0, #MODER]
ldr r2, =0x000000FF
bics r1, r2
str r1, [r0, #MODER]

ldr r1, [r0, #MODER]
ldr r2, =0x0003FF00
bics r1, r2
ldr r2, =0x00015500
orrs r1, r2
str r1, [r0, #MODER]

ldr r0, =GPIOC
ldr r1, [r0, #PUPDR]
ldr r2, =0x000000FF
bics r1, r2
ldr r2, =0x000000aa
orrs r1, r2
str r1, [r0, #PUPDR]
pop {PC}

//============================================================================
// TIM6_ISR() {
//   TIM6->SR &= ~TIM_SR_UIF
//   if (GPIOC->ODR & (1<<8))
//     GPIOC->BRR = 1<<8;
//   else
//     GPIOC->BSRR = 1<<8;
// }
.type TIM6_DAC_IRQHandler %function
.global TIM6_DAC_IRQHandler
TIM6_DAC_IRQHandler:
push {r4-r7,LR}
ldr r0, =TIM6
ldr r1, [r0, #TIM_SR]
ldr r2, =TIM_SR
//ldr r3, [r2, #TIM_SR_UIF]
ldr r3, =TIM_SR_UIF
bics r1, r3
str r1, [r0, #TIM_SR]
//TIM6->SR &= ~TIM_SR_UIF

ldr r0, =GPIOC
ldr r1, [r0, #ODR]
movs r2, #1
lsls r2, r2, #8
ands r1, r2

cmp r1, #0
beq irqelse1
irqif1:
str r2, [r0, #BRR]
b irqendif1
irqelse1:
str r2, [r0, #BSRR]
irqendif1:


pop {r4-r7,PC}
//============================================================================
// Implement the setup_tim6 subroutine below.  Follow the instructions in the
// lab text.
.global setup_tim6
setup_tim6:
push {LR}
ldr r0, =RCC
ldr r1, [r0, #APB1ENR]
ldr r2, =0x10
orrs r1, r2
str r1, [r0, #APB1ENR]

ldr r0, =TIM6
ldr r1, =47999
str r1, [r0, #TIM_PSC]

ldr r1, =499
str r1, [r0, #TIM_ARR]

ldr r1, [r0, #TIM_DIER]
ldr r2, = TIM_DIER_UIE
orrs r1, r2
str r1, [r0, #TIM_DIER]

ldr r1, [r0, #TIM_CR1]
ldr r2, =TIM_CR1_CEN
orrs r1, r2
str r1, [r0, #TIM_CR1]

ldr r0, =NVIC
ldr r3, =ISER
ldr r2, =1<<TIM6_DAC_IRQn
str r2, [r0, r3]
pop {PC}
//============================================================================
// void show_char(int col, char ch) {
//   GPIOB->ODR = ((col & 7) << 8) | font[ch];
// }
.global show_char
show_char:
push {r4-r7,lr}
movs r2, #7
ands r0, r2
ldr r2, =GPIOB

lsls r4, r0, #8
ldr r6, =font
ldrb r5, [r6, r1]
orrs r4, r5
movs r3, r4
str r3, [r2, #ODR]
pop {r4-r7,pc}

//============================================================================
// nano_wait(int x)
// Wait the number of nanoseconds specified by x.
.global nano_wait
nano_wait:
	subs r0,#83
	bgt nano_wait
	bx lr

//============================================================================
// This function is provided for you to fill the LED matrix with AbCdEFg.
// It is a very useful function.  Study it carefully.
.global fill_alpha
fill_alpha:
	push {r4,r5,lr}
	movs r4,#0
fillloop:
	movs r5,#'A' // load the character 'A' (integer value 65)
	adds r5,r4
	movs r0,r4
	movs r1,r5
	bl   show_char
	adds r4,#1
	movs r0,#7
	ands r4,r0
	ldr  r0,=1000000
	bl   nano_wait
	b    fillloop
	pop {r4,r5,pc} // not actually reached

//============================================================================
// void drive_column(int c) {
//   c = c & 3;
//   GPIOC->BSRR = 0xf00000 | (1 << (c + 4));
// }
.global drive_column
drive_column:
push {r4,lr}
movs r1, #3
ands r0, r1
ldr r1, =GPIOC
ldr r2, [r1, #BSRR]
ldr r3, =0xf00000
movs r4, #1
adds r0, #4
lsls r4, r0
orrs r3, r4
movs r2, r3
str r2, [r1, #BSRR]
movs r0, r2
pop {r4, pc}

//============================================================================
// int read_rows(void) {
//   return GPIOC->IDR & 0xf;
// }
.global read_rows
read_rows:
push {LR}
ldr r1, =GPIOC
ldr r2, [r1, #IDR]
ldr r3, =0xf
ands r2, r3
movs r0, r2
pop {PC}
//============================================================================
// char rows_to_key(int rows) {
//   int n = (col & 0x3) * 4; // or int n = (col << 30) >> 28;
//   do {
//     if (rows & 1)
//       break;
//     n ++;
//     rows = rows >> 1;
//   } while(rows != 0);
//   char c = keymap[n];
//   return c;
// }

.global rows_to_key
rows_to_key:
push {r4-r7,lr}
movs r7,r0 //row is r7
ldr r5, =col
ldrb r6, [r5]
ldr r2, =0x3
ands r6, r2
movs r2, #4
muls r6, r6, r4 //r6 is n
do1:
rtkif1:
movs r0, r7
movs r3, #1
ands r0, r3
cmp r0, #0
bne rtkendif1

rtkelse1:
adds r6, #1 //n ++;
lsrs r7, r7, #1 //rows = rows >> 1;

cmp r7, #0 //while(rows != 0);
bne rtkif1
rtkendif1:

ldr r1, =keymap
ldrb r0, [r1, r6]// char c = keymap[n];
//return c;

pop {r4-r7,pc}

//============================================================================
// TIM7_ISR() {
//    TIM7->SR &= ~TIM_SR_UIF
//    int rows = read_rows();
//    if (rows != 0) {
//        char key = rows_to_key(rows);
//        handle_key(key);
//    }
//    char ch = disp[col];
//    show_char(col, ch);
//    col = (col + 1) & 7;
//    drive_column(col);
// }
.type TIM7_IRQHandler %function
.global TIM7_IRQHandler
TIM7_IRQHandler:


//============================================================================
// Implement the setup_tim7 subroutine below.  Follow the instructions
// in the lab text.
.global setup_tim7
setup_tim7:
push {LR}
ldr r0, =RCC
ldr r1, [r0, #APB1ENR]
ldr r2, =0x10
orrs r1, r2
str r1, [r0, #APB1ENR]

ldr r0, =TIM7
ldr r1, =4799
str r1, [r0, #TIM_PSC]

ldr r1, =9
str r1, [r0, #TIM_ARR]

ldr r1, [r0, #TIM_DIER]
ldr r2, = TIM_DIER_UIE
orrs r1, r2
str r1, [r0, #TIM_DIER]

ldr r1, [r0, #TIM_CR1]
ldr r2, =TIM_CR1_CEN
orrs r1, r2
str r1, [r0, #TIM_CR1]

ldr r0, =NVIC
ldr r3, =ISER
ldr r2, =1<<TIM7_IRQn
str r2, [r0, r3]

//============================================================================
// void handle_key(char key)
// {
//     if (key == 'A' || key == 'B' || key == 'D')
//         mode = key;
//     else if (key &gt;= '0' && key &lt;= '9')
//         thrust = key - '0';
// }
.global handle_key
handle_key:
push {LR}
keyif1cond1:
movs r1, #65
cmp r0, r1
beq keyif1

keyif1cond2:
movs r1, #66
cmp r0, r1
beq keyif1

keyif1cond3:
movs r1, #68
cmp r0, r1
bne keyendif1
keyif1:
ldr r2, =mode
strb r0, [r2]

keyendif1:

keyelifcond1:
cmp r0, #0
blt keyelifend1

keyelifcond2:
cmp r0, #9
bgt keyelifend1

keyelif1:
subs r0, #30
ldr r2, =thrust
str r0, [r2]
keyelifend1:
pop {PC}
//============================================================================
// void write_display(void)
// {
//     if (mode == 'C')
//         snprintf(disp, 9, "Crashed");
//     else if (mode == 'L')
//         snprintf(disp, 9, "Landed "); // Note the extra space!
//     else if (mode == 'A')
//         snprintf(disp, 9, "ALt%5d", alt);
//     else if (mode == 'B')
//         snprintf(disp, 9, "FUEL %3d", fuel);
//     else if (mode == 'D')
//         snprintf(disp, 9, "Spd %4d", velo);
// }


//============================================================================
// void update_variables(void)
// {
//     fuel -= thrust;
//     if (fuel &lt;= 0) {
//         thrust = 0;
//         fuel = 0;
//     }
//
//     alt += velo;
//     if (alt &lt;= 0) { // we've reached the surface
//         if (-velo &lt; 10)
//             mode = 'L'; // soft landing
//         else
//             mode = 'C'; // crash landing
//         return;
//     }
//
//     velo += thrust - 5;
// }


//============================================================================
// TIM14_ISR() {
//    // acknowledge the interrupt
//    update_variables();
//    write_display();
// }

.global check_disp_moiz
check_disp_moiz:
push {r4, lr}
bl enable_ports
loop1_moiz:
movs r4, #0
loop2_moiz:
cmp r4, #8
beq loop1_moiz
movs r1, #1
lsls r1, r4
lsls r3, r4, #8
orrs r3, r3, r1
ldr r1, =GPIOB
str r3, [r1, #ODR]
ldr  r0,=1000000
bl   nano_wait
adds r4, #1
b loop2_moiz
pop {r4, pc}

//============================================================================
// Implement setup_tim14 as directed.
.global setup_tim14
setup_tim14:


.global login
login: .string "xyz" // Replace with your login.
.balign 2

.global main
main:
	//bl check_wiring
	//bl fill_alpha
	bl autotest
	bl enable_ports
	bl check_disp_moiz
	bl setup_tim6
	bl setup_tim7
	bl setup_tim14
snooze:
	wfi
	b  snooze
	// Does not return.

//============================================================================
// Map the key numbers in the history array to characters.
// We just use a string for this.
.global keymap
keymap:
.string "DCBA#9630852*741"

//============================================================================
// This table is a *font*.  It provides a mapping between ASCII character
// numbers and the LED segments to illuminate for those characters.
// For instance, the character '2' has an ASCII value 50.  Element 50
// of the font array should be the 8-bit pattern to illuminate segments
// A, B, D, E, and G.  Spread out, those patterns would correspond to:
//   .GFEDCBA
//   01011011 = 0x5b
// Accessing the element 50 of the font table will retrieve the value 0x5b.
//
.global font
font:
.space 32
.byte  0x00 // 32: space
.byte  0x86 // 33: exclamation
.byte  0x22 // 34: double quote
.byte  0x76 // 35: octothorpe
.byte  0x00 // dollar
.byte  0x00 // percent
.byte  0x00 // ampersand
.byte  0x20 // 39: single quote
.byte  0x39 // 40: open paren
.byte  0x0f // 41: close paren
.byte  0x49 // 42: asterisk
.byte  0x00 // plus
.byte  0x10 // 44: comma
.byte  0x40 // 45: minus
.byte  0x80 // 46: period
.byte  0x00 // slash
.byte  0x3f, 0x06, 0x5b, 0x4f, 0x66, 0x6d, 0x7d, 0x07
.byte  0x7f, 0x67
.space 7
// Uppercase alphabet
.byte  0x77, 0x7c, 0x39, 0x5e, 0x79, 0x71, 0x6f, 0x76, 0x30, 0x1e, 0x00, 0x38, 0x00
.byte  0x37, 0x3f, 0x73, 0x7b, 0x31, 0x6d, 0x78, 0x3e, 0x00, 0x00, 0x00, 0x6e, 0x00
.byte  0x39 // 91: open square bracket
.byte  0x00 // backslash
.byte  0x0f // 93: close square bracket
.byte  0x00 // circumflex
.byte  0x08 // 95: underscore
.byte  0x20 // 96: backquote
// Lowercase alphabet
.byte  0x5f, 0x7c, 0x58, 0x5e, 0x79, 0x71, 0x6f, 0x74, 0x10, 0x0e, 0x00, 0x30, 0x00
.byte  0x54, 0x5c, 0x73, 0x7b, 0x50, 0x6d, 0x78, 0x1c, 0x00, 0x00, 0x00, 0x6e, 0x00
.balign 2

//============================================================================
// Data structures for this experiment.
//
.data
.global col
.global disp
.global mode
.global thrust
.global fuel
.global alt
.global velo
disp: .string "Hello..."
col: .byte 0
mode: .byte 'A'
thrust: .byte 0
.balign 4
.hword 0 // put this here to make sure next hword is not word-aligned
fuel: .hword 800
.hword 0 // put this here to make sure next hword is not word-aligned
alt: .hword 4500
.hword 0 // put this here to make sure next hword is not word-aligned
velo: .hword 0
