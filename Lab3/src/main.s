.syntax unified
.cpu cortex-m0
.fpu softvfp
.thumb

//==================================================================
// ECE 362 Lab Experiment 3
// General Purpose I/O
//==================================================================

.equ  RCC,      0x40021000
.equ  AHBENR,   0x014
.equ  GPIOAEN,  0x20000
.equ  GPIOBEN,  0x40000
.equ  GPIOCEN,  0x80000
.equ  GPIOA,    0x48000000
.equ  GPIOB,    0x48000400
.equ  GPIOC,    0x48000800
.equ  MODER,    0x00 
.equ  PUPDR,    0x0c
.equ  IDR,      0x10 
.equ  ODR,      0x14
.equ  BSRR,     0x18 
.equ  BRR,      0x28 

//==========================================================
// initb:
// Enable Port B in the RCC AHBENR register and configure
// the pins as described in section 2.1 of the lab
// No parameters.
// No expected return value.
.global initb
initb:
    push    {lr}
    // Student code goes here
	//enable the RCC clock for Port B
	ldr r0, =RCC
	ldr r1,[r0, #AHBENR]
	ldr r2, =GPIOBEN
	orrs r1, r2
	str r1, [r0, #AHBENR]

	//set pins PB8-PB11 as outputs
	ldr r0, =GPIOB
	ldr r1, [r0, #MODER]
	ldr r2, =0x00FF0000
	bics r1, r2
	ldr r2, =0x00550000
	orrs r1, r2
	str r1, [r0, #MODER]

	//set pins PB0 & PB4 as inputs
	ldr r0, =GPIOB
	ldr r1, [r0, #MODER]
	ldr r2, =0x00000303
	bics r1, r2
	str r1, [r0, #MODER]
    // End of student code
    pop     {pc}

//==========================================================
// initc:
// Enable Port C in the RCC AHBENR register and configure
// the pins as described in section 2.2 of the lab
// No parameters.
// No expected return value.

.global initc
initc:
    push    {lr}
    // Student code goes here
    //pins 4, 5, 6 and 7 of Port C as outputs

    ldr r0, =RCC
	ldr r1,[r0, #AHBENR]
	ldr r2, =GPIOCEN
	orrs r1, r2
	str r1, [r0, #AHBENR]

	ldr r0, =GPIOC
	ldr r1, [r0, #MODER]
	ldr r2, =0x0000FF00
	bics r1, r2
	ldr r2, =0x00005500
	orrs r1, r2
	str r1, [r0, #MODER]

	//pins 0, 1, 2, and 3 as inputs
	ldr r0, =GPIOC
	ldr r1, [r0, #MODER]
	ldr r2, =0x000000FF
	bics r1, r2
	str r1, [r0, #MODER]

	//internal pull down resistors by setting the relevant bits in the PUPDR register
	ldr r0, =GPIOC
	ldr r1, [r0, #PUPDR]
	ldr r2, =0x000000FF
	bics r1, r2
	ldr r2, =0x000000aa
	orrs r1, r2
	str r1, [r0, #PUPDR]


    // End of student code
    pop     {pc}

//==========================================================
// setn:
// Set given pin in GPIOB to given value in ODR
// Param 1 - pin number
// param 2 - value [zero or non-zero]
// No expected retern value.
.global setn
setn:
    push    {lr}
    // Student code goes here
	ldr r3, =GPIOB
	ldr r2, =0x0001
	lsls r2, r0

	cmp r1, #0
	beq else1
	str r2, [r3, #BSRR]
	movs r0, r2
	pop     {pc}


	else1: //second parameter is 0
	str r2, [r3, #BRR]
	movs r0, r2
    // End of student code
    pop     {pc}

//==========================================================
// readpin:
// read the pin given in param 1 from GPIOB_IDR
// Param 1 - pin to read
// No expected return value.
.global readpin
readpin:
    push    {lr}
    // Student code goes here
	ldr r1, =GPIOB
	ldr r2, [r1, #IDR]
	ldr r3, =0x1
	lsls r3, r0
	bics r3, r2
	cmp r3, #0
	beq else2
	if2:
	ldr r0, =0x0
	pop     {pc}

	else2:
	ldr r0, =0x1

    // End of student code
    pop     {pc}

//==========================================================
// buttons:
// Check the pushbuttons and turn a light on or off as 
// described in section 2.6 of the lab
// No parameters.
// No return value
.global buttons
buttons:
    push    {lr}
    // Student code goes here
    //setn(8, readpin(0));
	ldr r0, =0x0
	bl readpin
	movs r1, r0
	ldr r0, =0x8
	bl setn

	//setn(9, readpin(4));
	ldr r0, =0x4
	bl readpin
	movs r1, r0
	ldr r0, =0x9
	bl setn
    // End of student code
    pop     {pc}

//==========================================================
// keypad:
// Cycle through columns and check rows of keypad to turn
// LEDs on or off as described in section 2.7 of the lab
// No parameters.
// No expected return value.
.global keypad
keypad:
    push    {r7,lr}
    // Student code goes here
	movs r7, #8 //r3=c

	for3:
	//GPIOC->ODR = c << 4;
	movs r2, r7
	lsls r2, #4
	ldr r1, =GPIOC
	str r2, [r1, #ODR]
	//GPIOC->ODR = c << 4;
	bl mysleep

	//int r = GPIOC->IDR & 0xf;
	ldr r1, =GPIOC
	ldr r2, [r1, #IDR]
	ldr r0, =0xf
	ands r2, r0 //r2 = r

	forif:
	cmp r7, #8
	bne forelif1

	ldr r0, =0x8
	movs r1, r2
	movs r2, #1
	ands r1, r2
	bl setn
	b forend

	forelif1:
	cmp r7, #4
	bne forelif2

	ldr r0, =0x9
	movs r1, r2
	movs r2, #2
	ands r1, r2
	bl setn
	b forend

	forelif2:
	cmp r7, #2
	bne forelse

	ldr r0, =0xa
	movs r1, r2
	movs r2, #4
	ands r1, r2
	bl setn
	b forend

	forelse:
	ldr r0, =0xb
	movs r1, r2
	movs r2, #8
	ands r1, r2
	bl setn
	b forend

	forend:
	lsrs r7, #1
	cmp r7, #0
	bgt for3

    // End of student code
    pop     {r7,pc}

//==========================================================
// mysleep:
// a do nothing loop so that row lines can be charged
// as described in section 2.7 of the lab
// No parameters.
// No expected return value.
.global mysleep
mysleep:
    push    {lr}
    // Student code goes here
	ldr r0, =0x0
	for2:
	adds r0, #1
	ldr r1, =0x3e8
	cmp r0, r1
	blt for2

    // End of student code
    pop     {pc}

//==========================================================
// The main subroutine calls everything else.
// It never returns.
.global main
main:
    push {lr}
    bl   autotest // Uncomment when most things are working
    bl   initb
    bl   initc
// uncomment one of the loops, below, when ready
//loop1:
//    bl   buttons
//    b    loop1
//loop2:
//    bl   keypad
//    b    loop2

    wfi
    pop {pc}
